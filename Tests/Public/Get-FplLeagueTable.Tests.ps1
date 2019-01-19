Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplLeagueTable' {
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
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page=1$'} {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic' 3>&1 | Should -Be 'The game is being updated. Please try again shortly.'
            }
        }
    }
}
