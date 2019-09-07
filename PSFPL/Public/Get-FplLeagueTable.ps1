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
        https://psfpl.readthedocs.io/en/master/functions/Get-FplLeagueTable
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
    begin {
        if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
            Write-Warning 'You must be logged in to view leagues'
            $Credential = Get-Credential -Message 'Please enter your FPL login details'
            Connect-Fpl -Credential $Credential
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'PipelineInput') {
            $Type = $League.Scoring
            $LeagueId = $League.LeagueId
        }
        $Results = do {
            $Page += 1
            $Url = 'https://fantasy.premierleague.com/api/leagues-{0}/{1}/standings/?page_new_entries=1&page_standings={2}' -f $Type.ToLower(), $LeagueId, $Page
            try {
                $Response = Invoke-RestMethod -Uri $Url -UseBasicParsing -WebSession $Script:FplSessionData['FplSession']
            }
            catch {
                Write-Warning "A $Type league with ID $LeagueId does not exist"
                return
            }
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
