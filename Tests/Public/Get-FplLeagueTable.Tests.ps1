Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplLeagueTable' {
        Context 'Normal circumstances' {
            BeforeAll {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page=1$'} {
                    [PSCustomObject]@{
                        standings = [PSCustomObject]@{
                            has_next = $true
                        }
                    }
                }
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page=2$'} {
                    [PSCustomObject]@{
                        standings = [PSCustomObject]@{
                            has_next = $false
                        }
                    }
                }
                Mock ConvertTo-FplObject {$true}
            }
            It 'loops through all the league standing pages' {
                $Results = Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Invoke-RestMethod 2 -Scope It
            }
            It 'processes parameter input' {
                $Result = Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/drf/leagues-classic-standings/12345?phase=1&le-page=1&ls-page=1'}
            }
            It 'processes pipeline input for an FplLeague object' {
                $League = [PSCustomObject]@{
                    PSTypeName = 'FplLeague'
                    LeagueId   = 56789
                    Scoring    = 'H2H'
                }

                $League | Get-FplLeagueTable
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/drf/leagues-h2h-standings/56789?phase=1&le-page=1&ls-page=1'}
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page=1$'} {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic' 3>&1 | Should -Be 'The game is being updated. Please try again shortly.'
            }
        }
        Context "When the league doesn't exist" {
            BeforeAll {
                Mock Invoke-RestMethod { throw }
                $Result = Get-FplLeagueTable -LeagueId 12345 -Type 'Classic' 3>&1
            }
            It "shows a warning when a league doesn't exist" {
                Assert-MockCalled Invoke-RestMethod
                $Result | Should -Be 'A Classic league with ID 12345 does not exist'
            }
        }
    }
}
