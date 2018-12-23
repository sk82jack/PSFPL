function Get-FplLeagueTable {
    <#
    .SYNOPSIS
        Retrieves an FPL league table
    .DESCRIPTION
        Retrieves an FPL league table given a league ID and league type
    .PARAMETER Id
        An FPL league Id
    .Parameter Type
        An FPL league type. This can either be 'Classic' or 'HeadToHead'
    .EXAMPLE
        Get-FplLeagueTable -Id 12345 -Type Classic

        This will show the league standings for the classic league of ID 12345
    .LINK
        https://psfpl.readthedocs.io/en/latest/functions/Get-FplLeagueTable
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeagueTable.ps1
    #>
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
