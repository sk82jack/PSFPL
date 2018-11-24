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

    git config user.email 'sk82jack@hotmail.com'
    git config user.name 'sk82jack'
    $GitHubUrl = 'https://{0}@github.com/sk82jack/PSFPL.git' -f $ENV:GITHUB_PAT
}

Task Default -Depends Test

Task Init {
    $lines
    Set-Location $ENV:BHProjectPath
    "Build System Details:"
    Get-Item ENV:BH*
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
    $CodeFiles = (Get-ChildItem $ENV:BHModulePath -Recurse -Include "*.psm1", "*.ps1").FullName
    $Params = @{
        Path                   = "$ENV:BHProjectPath\Tests"
        OutputFile             = "$ENV:BHProjectPath\$TestFile"
        OutputFormat           = 'NUnitXml'
        CodeCoverage           = $CodeFiles
        CodeCoverageOutputFile = "$ENV:BHProjectPath\$CoverageFile"
        Show                   = 'Fails'
        PassThru               = $true
    }
    $TestResults = Invoke-Pester @Params
    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol

    #Remove-Item "$ENV:BHProjectPath\$TestFile" -Force -ErrorAction SilentlyContinue
    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task BuildDocs -depends Test {
    $lines
    Import-Module -Name $env:BHPSModuleManifest -Force
    $DocFolder = "$env:BHModulePath\docs"
    $YMLtext = (Get-Content "$env:BHModulePath\header-mkdocs.yml") -join "`n"
    $YMLtext = "$YMLtext`n  - Change Log: ChangeLog.md`n"
    $YMLText = "$YMLtext  - Functions:`n"

    "`n`tRemoving old documentation"
    $parameters = @{
        Recurse     = $true
        Force       = $true
        Path        = "$DocFolder\functions"
        ErrorAction = 'SilentlyContinue'
    }
    $null = Remove-Item @parameters

    "`n`tBuilding documentation"
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
        $YMLText = "{0}{1}`n" -f $YMLText, $Part
        $Part
    }
    $YMLtext | Set-Content -Path "$env:BHModulePath\mkdocs.yml"
    Copy-Item -Path "$env:BHModulePath\README.md" -Destination "$DocFolder\index.md" -Force
    Update-Changelog -Path "$env:BHModulePath\CHANGELOG.md" -ReleaseVersion ################################################################
    Convertfrom-Changelog -Path "$env:BHModulePath\CHANGELOG.md" -OutputPath "$DocFolder\ChangeLog.md"

    "`tPushing built docs to GitHub"
    git add "$DocFolder\*"
    git add "$env:BHModulePath\mkdocs.yml"
    git add "$env:BHModulePath\CHANGELOG.md"
    git commit -m "Update docs for release ***NO_CI***"
    git push $GitHubUrl HEAD.master
    "`n"
}

Task Build -Depends BuildDocs {
    $lines
    "`n"

    # Compile seperate ps1 files into the psm1
    $Stringbuilder = [System.Text.StringBuilder]::new()
    $Folders = Get-ChildItem -Path $env:BHModulePath -Directory
    foreach ($Folder in $Folders.Name) {
        [void]$Stringbuilder.AppendLine("Write-Verbose 'Importing from [$env:BHModulePath\$Folder]'" )
        if (Test-Path "$env:BHModulePath\$Folder") {
            $Files = Get-ChildItem "$env:BHModulePath\$Folder\*.ps1"
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
    Set-ModuleFunctions
    "`tSetting module aliases"
    Set-ModuleAliases

    # Bump the module version if we didn't already
    Try {
        $GalleryVersion = Find-NugetPackage -Name $env:BHProjectName -PackageSourceUrl 'http://psrepositorychi01.phe.gov.uk/nuget/PowerShell' -IsLatest -ErrorAction Stop
        $GitlabVersion = Get-MetaData -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -ErrorAction Stop
        if ($GalleryVersion.Version -ge $GitlabVersion) {
            Step-ModuleVersion -Path $env:BHPSModuleManifest -By Build
        }
    }
    Catch {
        "`tFailed to update version for '$env:BHProjectName': $_.`nContinuing with existing version"
    }
    "`n"
}

Task Deploy -Depends Build {
    $lines

    $Params = @{
        Path    = "$ENV:BHProjectPath\Build"
        Force   = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    "`tInvoking PSDeploy"
    Invoke-PSDeploy @Verbose @Params
}
