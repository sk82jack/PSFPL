function Get-FplFixture {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [int]
        $Gameweek,

        [Parameter()]
        [ValidateSet(
            'Arsenal', 'Bournemouth', 'Brighton', 'Burnley', 'Cardiff', 'Chelsea', 'Crystal Palace',
            'Everton', 'Fulham', 'Huddersfield', 'Leicester', 'Liverpool', 'Man City', 'Man Utd',
            'Newcastle', 'Southampton', 'Spurs', 'Watford', 'West Ham', 'Wolves'
        )]
        [string]
        $Club
    )

    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/fixtures/' -UseBasicParsing
    $Fixtures = ConvertTo-FplObject -InputObject $Response -Type 'FplFixture' | Sort-Object Gameweek, KickOffTime
    $Fixtures.Where{
        ($Gameweek -eq 0 -or $_.Gameweek -eq $Gameweek) -and
        $_.ClubH + $_.ClubA -match $Club
    }
}
