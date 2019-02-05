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
$Refs = git show-ref | Foreach-Object {
    $Commit, $Ref = $_.split()
    [PSCustomObject]@{
        Commit = $Commit
        Ref    = $Ref
    }
}
$Branches = $Refs.Where{$_.Commit -eq $CommitID}.Ref
if (
    $env:BHModulePath -and
    $env:BHBuildSystem -ne 'Unknown' -and
    [version]::TryParse($env:BHBranchName, [ref]$null) -and
    $Branches -eq 'refs/remotes/origin/master'
) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHModulePath
            To PSGallery
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
    "`t* You have tagged the master branch (Tagged branches: $($Branches -join ', '))" |
        Write-Error
}
