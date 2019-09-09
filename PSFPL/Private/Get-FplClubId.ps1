function Get-FplClubId {
    <#
    .SYNOPSIS
        Retrieves a hashtable of club IDs to club names
    .DESCRIPTION
        Retrieves a hashtable of club IDs to club names
    .EXAMPLE
        Get-FplClubId
    .LINK
        https://github.com/sk82jack/PSFPL/
    #>
    [CmdletBinding()]
    param ()
    $Hashtable = @{}

    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['Clubs'])) {
        $Bootstrap = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/bootstrap-static/' -UseBasicParsing
        $Script:FplSessionData = @{
            ElementTypes = $Bootstrap.element_types
            Clubs        = $Bootstrap.teams
            Players      = $Bootstrap.elements
        }
    }

    foreach ($Club in $Script:FplSessionData['Clubs']) {
        $Hashtable[$Club.id] = $Club.name
    }
    $Hashtable
}
