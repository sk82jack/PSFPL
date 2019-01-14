function Get-FplTeam {
    <#
    .SYNOPSIS
        Retrieve information about an FPL team
    .DESCRIPTION
        Retrieve information about an FPL team either by a specified team ID or get your own team by logging in with Connect-FPL
    .PARAMETER TeamId
        A team ID to retrieve information about
    .EXAMPLE
        Connect-Fpl -Email MyEmail@hotmail.com
        $MyTeam = Get-FplTeam

        Retrieves information about your own team
    .EXAMPLE
        Get-FplTeam -TeamId 12345

        Retrieves information about the team with the ID 12345
    .LINK
        https://psfpl.readthedocs.io/en/latest/functions/Get-FplTeam
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeam.ps1
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $TeamId
    )

    if ($TeamId -gt 0) {
        $Response = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/drf/entry/$TeamId" -UseDefaultCredentials
        ConvertTo-FplObject -InputObject $Response.entry -Type 'FplTeam'
    }
    elseif ($script:FplSession) {
        Get-FplUserTeam
    }
    else {
        Write-Warning 'Please either login with the Connect-FPL function or specify a team ID'
    }
}
