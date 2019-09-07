Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplElementId' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    elements = @(
                        [pscustomobject]@{id = 1; web_name = 'Cech'},
                        [pscustomobject]@{id = 2; web_name = 'BellerÃ­n'}
                    )
                }
            }
            $Result = Get-FplElementId
        }
        It 'Parses objects into hashtable' {
            $Result | Should -BeOfType [Hashtable]
            $Result.Count | Should -Be 2
            $Result[1] | Should -Be 'Cech'
        }
        It 'Converts diacritic characters' {
            $Result[2] | Should -Be 'Bellerin'
        }
    }
}
