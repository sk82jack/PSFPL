param ($Task = 'Default')

# dependencies
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
$NuGetDirectory = "C:\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet\"
$NuGetPath = Join-Path -Path $NuGetDirectory -ChildPath "NuGet.exe"
Try {
    $null = Resolve-Path -Path $NuGetPath -ErrorAction Stop
}
Catch {
    New-Item -Path (Split-Path -Path $NuGetPath -Parent) -ItemType Directory
    Invoke-RestMethod https://nuget.org/nuget.exe -OutFile $NuGetPath
}

$env:PATH = '{0};{1}' -f $NugetDirectory, $env:PATH

if (-not (Get-Module -ListAvailable PSDepend)) {
    & (Resolve-Path "$PSScriptRoot\helpers\Install-PSDepend.ps1")
}
Import-Module PSDepend
$null = Invoke-PSDepend -Path "$PSScriptRoot\build.requirements.psd1" -Install -Import -Force

Set-BuildEnvironment -Force

Write-Output "  Invoke Psake"
Invoke-psake -buildFile $PSScriptRoot\psake.ps1 -taskList $Task -nologo
exit ([int](-not $psake.build_success))
