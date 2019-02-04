# Generic module deployment.
#
# ASSUMPTIONS:
#
# * folder structure either like:
#
#   - RepoFolder
#     - This PSDeploy file
#     - ModuleName
#       - ModuleName.psd1
#
#   OR the less preferable:
#   - RepoFolder
#     - RepoFolder.psd1
#
# * Nuget key in $ENV:NugetApiKey
#
# * Set-BuildEnvironment from BuildHelpers module has populated ENV:BHModulePath and related variables

# Publish to gallery with a few restrictions
$CommitID = git rev-list -n 1 $env:BHBranchName
$BranchesContainMaster = (git branch --contains $CommitID).Trim() -match '^\*?master$'
if (
    $env:BHModulePath -and
    $env:BHBuildSystem -ne 'Unknown' -and
    [version]::TryParse($env:BHBranchName, [ref]$null) -and
    $BranchesContainMaster
) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHModulePath
            To PHERepo
            WithOptions @{
                ApiKey = $ENV:PSREPO_APIKEY
            }
        }
    }
}
else {
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are deploying from a tagged release (Current tag/branch: $ENV:BHBranchName)`n" +
    "`t* You have tagged the master branch (Tagged branch contains the master branch: $BranchesContainMaster)" |
        Write-Host
}
