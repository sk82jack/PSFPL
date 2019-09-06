function Get-FplElementId {
    <#
    .SYNOPSIS
        Retrieves a hashtable of player IDs to player names
    .DESCRIPTION
        Retrieves a hashtable of player IDs to player names
    .EXAMPLE
        Get-FplElementId
    .LINK
        https://github.com/sk82jack/PSFPL/
    #>
    [CmdletBinding()]
    param ()
    $Hashtable = @{}
    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['Players'])) {
        $Bootstrap = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/bootstrap-static/' -UseBasicParsing
        $Script:FplSessionData = @{
            ElementTypes = $Bootstrap.element_types
            Clubs        = $Bootstrap.teams
            Players      = $Bootstrap.elements
        }
    }
    foreach ($Element in $Script:FplSessionData['Players']) {
        $DiacriticName = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($Element.web_name))
        $Hashtable[$Element.id] = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($DiacriticName))
    }
    $Hashtable
}
