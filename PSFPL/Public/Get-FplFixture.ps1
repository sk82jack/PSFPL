function Get-FplFixture {
    <#
    .SYNOPSIS
        Retrieves a list of FPL fixtures
    .DESCRIPTION
        Retrieves a list of FPL fixtures
    .PARAMETER Gameweek
        Retrieve the fixtures from a specified gameweek
    .PARAMETER Club
        Retrieve the fixtures for a specified club
    .EXAMPLE
        Get-FplFixture

        This will list all of the fixtures throughout the season
    .EXAMPLE
        Get-FplFixture -Gameweek 14

        This will list the fixtures from gameweek 14
    .EXAMPLE
        Get-FplFixture -Club Liverpool

        This will list all of the fixtures for Liverpool FC
    .EXAMPLE
        Get-FplFixture -Club Chelsea -Gameweek 2

        This will get the Chelsea FC fixture in gameweek 2
    .LINK
        https://psfpl.readthedocs.io/en/latest/functions/Get-FplFixture
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplFixture.ps1
    #>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
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

    process {
        $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/fixtures/' -UseBasicParsing
        if ($Response -match 'The game is being updated.') {
            Write-Warning 'The game is being updated. Please try again shortly.'
            return
        }
        $Fixtures = ConvertTo-FplObject -InputObject $Response -Type 'FplFixture' | Sort-Object Gameweek, KickOffTime
        $Fixtures.Where{
            ($Gameweek -eq 0 -or $_.Gameweek -eq $Gameweek) -and
            $_.ClubH + $_.ClubA -match $Club
        }
    }
}
