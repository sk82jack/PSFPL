function Get-FplFixture {
    [CmdletBinding()]
    Param (

    )

    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/fixtures/' -UseBasicParsing
    $Fixtures = ConvertTo-FplObject -InputObject $Response -Type 'FplFixture'
}
