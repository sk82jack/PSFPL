function Get-FplUserTeam {
    [CmdletBinding()]
    param ()
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/transfers' -UseDefaultCredentials -WebSession $Script:FplSession
    ConvertTo-FplObject -InputObject $Response.entry -Type 'FplTeam'
}
