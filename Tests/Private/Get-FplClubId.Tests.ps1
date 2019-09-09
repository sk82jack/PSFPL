Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplClubId' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    teams = @(
                        [pscustomobject]@{id = 1; name = 'Arsenal'},
                        [pscustomobject]@{id = 2; name = 'Bournemouth'}
                    )
                }
            }
            $Result = Get-FplClubId
        }
        It 'Parses objects into hashtable' {
            $Result[1] | Should -Be 'Arsenal'
            $Result[2] | Should -Be 'Bournemouth'
        }
    }
}
