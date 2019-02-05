function Get-FplTeamPlayer {
    <#
    .SYNOPSIS
        Retrieves the player information within a team from a certain gameweek.
    .DESCRIPTION
        Retrieves the player information within a team from a certain gameweek.
        If no team ID or gameweek is supplied it will request to authenticate to get the users team and current gameweek.
    .PARAMETER TeamId
        The ID of the team to retrieve the player information
    .PARAMETER Gameweek
        The gameweek of which to retrieve the player information from
    .EXAMPLE
        Get-FplTeamPlayer

        This will prompt the user to supply credentials and return the user's player information from the current gameweek
    .EXAMPLE
        Get-FplTeamPlayer -TeamID 12345

        This will get the player information for the team with ID 12345 from the current gameweek
    .EXAMPLE
        Get-FplTeamPlayer -TeamID 12345 -Gameweek 12

        This will get the player information for the team with ID 12345 from gameweek 12
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Get-FplTeamPlayer
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeamPlayer.ps1
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $TeamId,

        [Parameter()]
        [int]
        $Gameweek
    )
    process {
        if ($TeamId -eq 0) {
            if (!$Script:FplSession) {
                Write-Warning 'No existing connection found'
                $Credential = Get-Credential -Message 'Please enter your FPL login details'
                Connect-Fpl -Credential $Credential
            }

            $TeamId = (Get-FplUserTeam).TeamId
        }

        if ($Gameweek -eq 0) {
            $Gameweek = (Get-FplGameweek -Current).Gameweek
        }

        $Response = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/drf/entry/$TeamId/event/$Gameweek/picks"
        if ($Response -match 'The game is being updated.') {
            Write-Warning 'The game is being updated. Please try again shortly.'
            return
        }
        ConvertTo-FplObject -InputObject $Response.picks -Type 'FplTeamPlayer'
    }
}
