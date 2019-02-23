function Get-FplUserTeam {
    <#
    .SYNOPSIS
        Retrieves the logged in users team
    .DESCRIPTION
        Retrieves the logged in users team
    .EXAMPLE
        Get-FplUserTeam
    .LINK
        https://github.com/sk82jack/PSFPL/
    #>
    [CmdletBinding()]
    param ()
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/transfers' -UseBasicParsing -WebSession $Script:FplSessionData['FplSession']
    ConvertTo-FplObject -InputObject $Response.entry -Type 'FplTeam'
}
