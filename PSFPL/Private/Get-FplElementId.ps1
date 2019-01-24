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
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/elements/' -UseBasicParsing
    $Hashtable = @{}
    foreach ($Element in $Response) {
        $DiacriticName = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($Element.web_name))
        $Hashtable[$Element.id] = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($DiacriticName))
    }
    $Hashtable
}
