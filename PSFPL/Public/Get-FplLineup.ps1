function Get-FplLineup {
    <#
    .SYNOPSIS
        Retrieves your team lineup for the upcoming gameweek
    .DESCRIPTION
        Retrieves your team lineup for the upcoming gameweek
    .EXAMPLE
        Get-FplLineup
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Get-FplLineup
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLineup.ps1
    #>

    [CmdletBinding()]
    param()

    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
        Write-Warning 'No existing connection found'
        $Credential = Get-Credential -Message 'Please enter your FPL login details'
        Connect-Fpl -Credential $Credential
    }

    $TeamId = (Get-FplUserTeam).TeamId

    $Response = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/drf/my-team/$TeamId/" -WebSession $FplSessionData['FplSession'] -UseBasicParsing

    ConvertTo-FplObject -InputObject $Response.Picks -Type 'FplLineup'
}
