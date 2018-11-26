Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplPlayer' {
        BeforeAll {
            Mock Invoke-RestMethod {$true}
            Mock ConvertTo-FplObject {
                @(
                    [pscustomobject]@{
                        Id   = 1
                        Name = 'Gameweek 1'
                    },
                    [pscustomobject]@{
                        Id   = 2
                        Name = 'Gameweek 2'
                    }
                )
            }
        }
        It 'Not defining a gameweek retrieves all gameweeks' {
            $Results = Get-FplGameweek
            $Results.count | Should -Be 2
        }
        It 'Filters correctly on the Gameeweek parameter' {
            $Result = Get-FplGameweek -Gameweek 1
            $Result.Name | Should -Be 'Gameweek 1'

            $Result = Get-FplGameweek -Gameweek 2
            $Result.Name | Should -Be 'Gameweek 2'
        }
    }
}
