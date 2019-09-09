# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    if (-not $ENV:BHProjectPath) {
        $ENV:BHProjectPath = Resolve-Path "$PSScriptRoot\.."
    }
    $PSVersion = $PSVersionTable.PSVersion.Major
    $lines = '----------------------------------------------------------------------'
    $Verbose = @{}
    if ($ENV:BHCommitMessage -match "!verbose") {
        $Verbose = @{Verbose = $True}
    }

    $GitSettings = git config --list --show-origin
    $GitName = ($GitSettings | Select-String -Pattern '^file:(.*?)\s+user\.name=(.*?)$').Matches.Groups
    $GitEmail = ($GitSettings | Select-String -Pattern '^file:(.*?)\s+user\.email=(.*?)$').Matches.Groups
}

TaskSetup {
    if ($GitEmail -and $GitEmail[1].Value) {
        git config -f $GitEmail[1].Value user.email 'pipeline@example.com'
    }
    else {
        git config --global user.email 'pipeline@example.com'
    }
    if ($GitName -and $GitName[1].Value) {
        git config -f $GitName[1].Value user.name 'pipeline'
    }
    else {
        git config --global user.name 'pipeline@example.com'
    }
}
TaskTearDown {
    if ($GitEmail -and $GitEmail[2].Value) {
        git config -f $GitEmail[1].Value user.email $GitEmail[2].Value
    }
    else {
        git config --global --unset user.email
    }
    if ($GitName -and $GitName[2].Value) {
        git config -f $GitName[1].Value user.name $GitName[2].Value
    }
    else {
        git config --global --unset user.name
    }
}
Task Default -Depends Test

Task Init {
    $lines
    Set-Location $ENV:BHProjectPath
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task SetBuildVersion -Depends Init {
    $lines

    "`n`tSetting git repository url"
    if (!$ENV:GITHUB_PAT) {
        Write-Error "GitHub personal access token not found"
    }
    $GitHubUrl = 'https://{0}@github.com/sk82jack/PSFPL.git' -f $ENV:GITHUB_PAT

    "`tSetting build version"
    $BuildVersionPath = "$ENV:BHProjectPath\BUILDVERSION.md"
    "|Build Version|`r`n|---|`r`n|$ENV:BUILD_NAME|" | Out-File -FilePath $BuildVersionPath -Force

    "`tPushing build version to GitHub"
    git add $BuildVersionPath
    git commit -m "Bump build version`n***NO_CI***"
    # --porcelain is to stop git sending output to stderr
    git push $GitHubUrl HEAD:master --porcelain
    "`n"
}

Task Test -Depends Init {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Testing links on github requires >= tls 1.2
    $SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Gather test results
    $TestFile = "TestResults.xml"
    $CoverageFile = "TestCoverage.xml"
    $CodeFiles = Get-ChildItem $ENV:BHModulePath -Recurse -Include "*.psm1", "*.ps1"
    $Params = @{
        Path                   = "$ENV:BHProjectPath\Tests"
        OutputFile             = "$ENV:BHProjectPath\$TestFile"
        OutputFormat           = 'NUnitXml'
        CodeCoverage           = $CodeFiles.FullName
        CodeCoverageOutputFile = "$ENV:BHProjectPath\$CoverageFile"
        Show                   = 'Fails'
        PassThru               = $true
    }
    $TestResults = Invoke-Pester @Params
    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol
    $TestSourceDirs = ($CodeFiles.DirectoryName | Sort-Object -Unique) -join ";"
    Write-Host "INFO [task.setvariable variable=CodeCoverageDirectories]$TestSourceDirs"
    Write-Host "##vso[task.setvariable variable=CodeCoverageDirectories]$TestSourceDirs"

    #Remove-Item "$ENV:BHProjectPath\$TestFile" -Force -ErrorAction SilentlyContinue
    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Build -Depends Test {
    $lines
    "`n"

    # Compile seperate ps1 files into the psm1
    $Stringbuilder = [System.Text.StringBuilder]::new()
    $Folders = Get-ChildItem -Path $env:BHModulePath -Directory
    foreach ($Folder in $Folders.Name) {
        [void]$Stringbuilder.AppendLine("Write-Verbose 'Importing from [$env:BHModulePath\$Folder]'" )
        if (Test-Path "$env:BHModulePath\$Folder") {
            $Files = Get-ChildItem "$env:BHModulePath\$Folder\*.ps1"
            if ($Folder -eq 'Public') {
                $PublicFunctions = $Files.BaseName
            }
            foreach ($File in $Files) {
                $Name = $File.Name
                "`tImporting [.$Name]"
                [void]$Stringbuilder.AppendLine("# .$Name")
                [void]$Stringbuilder.AppendLine([System.IO.File]::ReadAllText($File.fullname))
            }
        }
        "`tRemoving folder [$env:BHModulePath\$Folder]"
        Remove-Item -Path "$env:BHModulePath\$Folder" -Recurse -Force
    }
    $ModulePath = Join-Path -Path $env:BHModulePath -ChildPath "$env:BHProjectName.psm1"
    "`tCreating module [$ModulePath]"
    Set-Content -Path $ModulePath -Value $Stringbuilder.ToString()

    # Load the module, read the exported functions & aliases, update the psd1 FunctionsToExport & AliasesToExport
    "`tSetting module functions"
    Set-ModuleFunctions -FunctionsToExport $PublicFunctions
    "`tSetting module aliases"
    Set-ModuleAliases

    # Set the module version from the release tag
    "`tUpdating the module manifest with the new version number"
    [version]$ReleaseVersion = git describe --tags
    $GalleryVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName -ErrorAction Stop
    if ($ReleaseVersion -lt $GalleryVersion) {
        Write-Error "Gallery version is higher than the release version. The release version must be increased"
    }
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $ReleaseVersion -ErrorAction stop
    "`n"
}

Task BuildDocs -depends Build {
    $lines
    "`n`tImporting the module and start building the yaml"
    "`t`tImporting from '$env:BHPSModuleManifest'"
    Import-Module -Name $env:BHPSModuleManifest -Global -Force -ErrorAction 'Stop'
    $DocFolder = "$env:BHProjectPath\docs"
    $YMLtext = (Get-Content "$env:BHProjectPath\header-mkdocs.yml") -join "`r`n"
    $YMLtext = "$YMLtext`r`n  - Change Log: ChangeLog.md`r`n"
    $YMLText = "$YMLtext  - Functions:`r`n"

    "`tRemoving old documentation"
    $Params = @{
        Recurse     = $true
        Force       = $true
        Path        = "$DocFolder\functions"
        ErrorAction = 'SilentlyContinue'
    }
    $null = Remove-Item @Params

    "`tBuilding documentation"
    if (!(Test-Path $DocFolder)) {
        New-Item -Path $DocFolder -ItemType Directory
    }
    $Params = @{
        Module       = $ENV:BHProjectName
        Force        = $true
        OutputFolder = "$DocFolder\functions"
        NoMetadata   = $true
    }
    New-MarkdownHelp @Params | foreach-object {
        $Function = $_.Name -replace '\.md', ''
        $Part = "    - {0}: functions/{1}" -f $Function, $_.Name
        $YMLText = "{0}{1}`r`n" -f $YMLText, $Part
        $Part
    }
    $YMLtext | Set-Content -Path "$env:BHProjectPath\mkdocs.yml"
    Copy-Item -Path "$env:BHProjectPath\README.md" -Destination "$DocFolder\index.md" -Force

    [version]$ReleaseVersion = git describe --tags

    $ChangeLogData = Get-ChangeLogData
    if (-not ($ChangeLogData.Unreleased.Data.psobject.properties.value -ne '')) {
        Write-Error 'Cannot perform a deploy without updating the changelog'
    }

    $Params = @{
        Path           = "$env:BHProjectPath\CHANGELOG.md"
        ReleaseVersion = $ReleaseVersion.ToString()
        LinkMode       = 'Automatic'
        LinkPattern    = @{
            FirstRelease  = "https://github.com/sk82jack/$ENV:BHProjectName/tree/v{CUR}"
            NormalRelease = "https://github.com/sk82jack/$ENV:BHProjectName/compare/v{PREV}..v{CUR}"
            Unreleased    = "https://github.com/sk82jack/$ENV:BHProjectName/compare/v{CUR}..HEAD"
        }
    }
    Update-Changelog @Params
    Convertfrom-Changelog -Path "$env:BHProjectPath\CHANGELOG.md" -OutputPath "$DocFolder\ChangeLog.md" -Format 'Release'
    "`n"
}

Task TestAfterBuild -Depends BuildDocs {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results
    $Params = @{
        Path     = "$ENV:BHProjectPath\Tests"
        Show     = 'Fails'
        PassThru = $true
    }
    $TestResults = Invoke-Pester @Params

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Deploy -Depends TestAfterBuild {
    $lines

    "`n`tTesting for PowerShell Gallery API key"
    if (-not $ENV:PSREPO_APIKEY) {
        Write-Error "PowerShell Gallery API key not found"
    }

    $Params = @{
        Path    = "$ENV:BHProjectPath\Build"
        Force   = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    "`tInvoking PSDeploy"
    Invoke-PSDeploy @Verbose @Params

    "`tSetting git repository url"
    if (!$ENV:GITHUB_PAT) {
        Write-Error "GitHub personal access token not found"
    }
    $GitHubUrl = 'https://{0}@github.com/sk82jack/PSFPL.git' -f $ENV:GITHUB_PAT

    "`tDeploying built docs to GitHub"
    git add "$env:BHProjectPath\docs\*"
    git add "$env:BHProjectPath\mkdocs.yml"
    git add "$env:BHProjectPath\CHANGELOG.md"
    git commit -m "Bump version to $ReleaseVersion`n***NO_CI***"
    # --porcelain is to stop git sending output to stderr
    git push $GitHubUrl HEAD:master --porcelain
}
