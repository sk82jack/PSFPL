function Get-FplLeagueTable {
    <#
    .SYNOPSIS
        Retrieves an FPL league table
    .DESCRIPTION
        Retrieves an FPL league table given a league ID and league type
    .PARAMETER LeagueId
        An FPL league Id
    .Parameter Type
        An FPL league type. This can either be 'Classic' or 'HeadToHead'
    .Parameter League
        This parameter allows you to pass in an FplLeague object directly which can be retrieved from Get-FplLeague
    .EXAMPLE
        Get-FplLeagueTable -Id 12345 -Type Classic

        This will show the league standings for the classic league of ID 12345
    .EXAMPLE
        Get-FplLeague | Where Name -eq 'My League' | Get-FplLeagueTable

        This will get the league standings for the league that your team is in called 'My League'
    .LINK
        https://psfpl.readthedocs.io/en/latest/functions/Get-FplLeagueTable
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeagueTable.ps1
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory,
            ParameterSetName = 'Default'
        )]
        [int]
        $LeagueId,

        [Parameter(
            Mandatory,
            ParameterSetName = 'Default'
        )]
        [ValidateSet('Classic', 'H2H')]
        [string]
        $Type,

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'PipelineInput'
        )]
        [PSTypeName('FplLeague')]
        $League
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'PipelineInput') {
            $Type = $League.Scoring
            $Id = $League.LeagueId
        }
        $Results = do {
            $Page += 1
            $Url = 'https://fantasy.premierleague.com/drf/leagues-{0}-standings/{1}?phase=1&le-page=1&ls-page={2}' -f $Type.ToLower(), $Id, $Page
            $Response = Invoke-RestMethod -Uri $Url -UseBasicParsing
            if ($Response -match 'The game is being updated.') {
                Write-Warning 'The game is being updated. Please try again shortly.'
                return
            }
            $Response
        }
        until (-not $Response.standings.has_next)

        ConvertTo-FplObject -InputObject $Results -Type 'FplLeagueTable'
    }
}
