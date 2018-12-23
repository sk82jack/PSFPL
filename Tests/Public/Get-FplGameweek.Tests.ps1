Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplPlayer' {
        BeforeAll {
            Mock Invoke-RestMethod {$true}
            Mock ConvertTo-FplObject {
                @(
                    [pscustomobject]@{
                        Id        = 1
                        Name      = 'Gameweek 1'
                        IsCurrent = $false
                    },
                    [pscustomobject]@{
                        Id        = 2
                        Name      = 'Gameweek 2'
                        IsCurrent = $true
                    }
                )
            }
        }
        It 'retrieves all gameweeks when no gameweek is defined' {
            $Results = Get-FplGameweek
            $Results.count | Should -Be 2
        }
        It 'filters correctly on the Gameeweek parameter' {
            $Result = Get-FplGameweek -Gameweek 1
            $Result.Name | Should -Be 'Gameweek 1'

            $Result = Get-FplGameweek -Gameweek 2
            $Result.Name | Should -Be 'Gameweek 2'
        }
        It 'accepts pipeline input correctly for the Gameweek parameter' {
            $Result = 1 | Get-FplGameweek
            $Result.Name | Should -Be 'Gameweek 1'
        }
        It 'gets the current gameweek correctly on the Current parameter' {
            $Result = Get-FplGameweek -Current
            $Result.Name | Should -Be 'Gameweek 2'
        }
    }
}
