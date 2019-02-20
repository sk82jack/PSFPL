function Get-FplLeague {
    <#
    .SYNOPSIS
        Lists the leagues that a team is a member of.
    .DESCRIPTION
        Lists the leagues that a team is a member of given a team ID.
        If no team ID is specified then it will list the leagues for your team. This requires an existing connection which can be created with Connect-Fpl.
        If there is no existing connection found it will prompt for credentials.
    .PARAMETER TeamId
        The team ID of the team to list the leagues of.
    .EXAMPLE
        Get-FplLeague

        This will list the leagues that your team is in.
    .EXAMPLE
        Get-FplLeague -TeamId 12345

        This will list the leagues that the team with the team ID of 12345 is in.
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Get-FplLeague
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeague.ps1
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [int]
        $TeamId
    )

    process {
        if ($TeamId -eq 0) {
            if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
                Write-Warning 'No existing connection found'
                $Credential = Get-Credential -Message 'Please enter your FPL login details'
                Connect-Fpl -Credential $Credential
            }

            $TeamId = (Get-FplUserTeam).TeamId
        }

        $Response = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/drf/entry/$TeamId" -UseDefaultCredentials
        if ($Response -match 'The game is being updated.') {
            Write-Warning 'The game is being updated. Please try again shortly.'
            return
        }
        ConvertTo-FplObject -InputObject $Response.leagues -Type 'FplLeague'
    }
}
