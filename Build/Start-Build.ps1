param ($Task = 'Default')

# dependencies
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
$NuGetPath = "C:\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"
Try {
    $null = Resolve-Path -Path $NuGetPath -ErrorAction Stop
}
Catch {
    New-Item -Path (Split-Path -Path $NuGetPath -Parent) -ItemType Directory
    Invoke-RestMethod https://nuget.org/nuget.exe -OutFile $NuGetPath
}
if (-not (Get-Module -ListAvailable PSDepend)) {
    & (Resolve-Path "$PSScriptRoot\helpers\Install-PSDepend.ps1")
}
Import-Module PSDepend
$null = Invoke-PSDepend -Path "$PSScriptRoot\build.requirements.psd1" -Install -Import -Force

Set-BuildEnvironment -Force

Write-Output "  Invoke Psake"
Invoke-psake -buildFile $PSScriptRoot\psake.ps1 -taskList $Task -nologo
exit ([int](-not $psake.build_success))
