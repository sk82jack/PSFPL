function Get-FplTeam {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $TeamId
    )

    if ($TeamId -gt 0) {
        $Response = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/drf/entry/$TeamId" -UseDefaultCredentials
    }
    elseif ($script:FplSession) {
        $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/transfers' -UseDefaultCredentials -WebSession $FplSession
    }
    else {
        Write-Warning 'Please either login with the Connect-FPL function or specify a team ID'
        return
    }

    ConvertTo-FplObject -InputObject $Response.entry -Type 'FplTeam'
}
