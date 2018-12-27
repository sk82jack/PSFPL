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
    }
}
