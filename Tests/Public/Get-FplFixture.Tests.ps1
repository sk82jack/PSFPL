Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplFixture' {
        BeforeAll {
            Mock Invoke-RestMethod {$true}
            Mock ConvertTo-FplObject {
                @(
                    [pscustomobject]@{
                        ClubH       = 'Man Utd'
                        ClubA       = 'Leicester'
                        Gameweek    = 1
                        KickoffTime = Get-Date '10/08/2018 20:00:00'
                    },
                    [pscustomobject]@{
                        ClubH       = 'Liverpool'
                        ClubA       = 'Everton'
                        Gameweek    = 1
                        KickoffTime = Get-Date '12/08/2018 13:30:00'
                    },
                    [pscustomobject]@{
                        ClubH       = 'Crystal Palace'
                        ClubA       = 'Liverpool'
                        Gameweek    = 2
                        KickoffTime = Get-Date '20/08/2018 20:00:00'
                    }
                )
            }
        }
        It 'Not defining a gameweek retrieves fixtures from all gameweeks' {
            $Results = Get-FplFixture
            $Results.count | Should -Be 3
        }
        It 'Filters correctly on the Gameeweek parameter' {
            $Result = Get-FplFixture -Gameweek 1
            $Result.Count | Should -Be 2
            foreach ($Gameweek in $Result.Gameweek) {
                $Gameweek | Should -Be 1
            }

            $Result = @(Get-FplFixture -Gameweek 2)
            $Result.Count | Should -Be 1
            foreach ($Gameweek in $Result.Gameweek) {
                $Gameweek | Should -Be 2
            }
        }
        It 'Filters correctly on the Club parameter' {
            $Result = Get-FplFixture -Club Liverpool
            $Result.Count | Should -Be 2
            foreach ($Fixture in $Result) {
                $Fixture.ClubH + $Fixture.ClubA | Should -Match 'Liverpool'
            }
        }
        It 'Filters correctly with multiple parameters' {
            $Result = @(Get-FplFixture -Gameweek 1 -Club 'Liverpool')
            $Result.count | Should -Be 1
            $Result.Gameweek | Should -Be 1
            $Result.ClubH + $Result.ClubA | Should -Match 'Liverpool'
        }
    }
}
