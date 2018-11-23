[cmdletbinding()]
param()
Write-Verbose "This psm1 is replaced in the build output. This file is only used for debugging."
Write-Verbose $PSScriptRoot
Write-Verbose 'Import everything in sub folders'
$FunctionFolders = @('Public', 'Private')
ForEach ($Folder in $FunctionFolders) {
    $FolderPath = Join-Path -Path $PSScriptRoot -ChildPath $Folder
    If (Test-Path -Path $FolderPath) {
        Write-Verbose -Message "Importing from $folder"
        $functions = Get-ChildItem -Path $folderPath -Filter '*.ps1'
        ForEach ($function in $functions) {
            Write-Verbose -Message "  Importing $($function.BaseName)"
            . $($function.FullName)
        }
    }
}
$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1').BaseName
Export-ModuleMember -Function $publicFunctions
