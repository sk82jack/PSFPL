function Get-FplLeagueTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Id,

        [Parameter()]
        [ValidateSet('Classic', 'HeadToHead')]
        [string]
        $Type
    )

    $Results = do {
        $Page += 1
        $Url = 'https://fantasy.premierleague.com/drf/leagues-{0}-standings/{1}?phase=1&le-page=1&ls-page={2}' -f $Type.ToLower(), $Id, $Page
        $Response = Invoke-RestMethod -Uri $Url -UseBasicParsing
        $Response
    }
    until (-not $Response.standings.has_next)

    ConvertTo-FplObject -InputObject $Results -Type 'FplLeagueTable'
}
