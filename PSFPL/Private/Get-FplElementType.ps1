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
    $Hashtable = @{}
    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['ElementTypes'])) {
        $Bootstrap = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/bootstrap-static/' -UseBasicParsing
        $Script:FplSessionData = @{
            ElementTypes = $Bootstrap.element_types
            Clubs        = $Bootstrap.teams
            Players      = $Bootstrap.elements
        }
    }
    foreach ($Element in $Script:FplSessionData['ElementTypes']) {
        $Hashtable[$Element.id] = $Element.singular_name
    }
    $Hashtable
}
