function Get-FplGameweek {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Gameweek
    )

    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/events/' -UseBasicParsing
    $Gameweeks = ConvertTo-FplObject -InputObject $Response -Type 'FplGameweek'
    if ($Gameweek -gt 0) {
        $Gameweeks.Where{$_.Id -eq $Gameweek}
    }
    else {
        $Gameweeks
    }
}
