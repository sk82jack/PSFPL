Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplClubId' {
        It 'Parses objects into hashtable' {
            Mock Invoke-RestMethod {
                @(
                    [pscustomobject]@{id = 1; name = 'Arsenal'},
                    [pscustomobject]@{id = 2; name = 'Bournemouth'}
                )
            }
            $Result = Get-FplClubId

            $Result[1] | Should -Be 'Arsenal'
            $Result[2] | Should -Be 'Bournemouth'
        }
    }
}
