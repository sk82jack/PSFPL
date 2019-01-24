function Get-FplElementType {
    <#
    .SYNOPSIS
        Retrieves a hashtable of position IDs to position names
    .DESCRIPTION
        Retrieves a hashtable of position IDs to position names
    .EXAMPLE
        Get-FplElementType
    .LINK
        https://github.com/sk82jack/PSFPL/
    #>
    [CmdletBinding()]
    param ()
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/element-types' -UseBasicParsing
    $ElementHash = @{}
    foreach ($Element in $Response) {
        $ElementHash[$Element.id] = $Element.singular_name
    }
    $ElementHash
}
