Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplClubId' {
        It 'Parses objects into hashtable' {
            Mock Invoke-RestMethod {
                @(
                    [pscustomobject]@{id = 1; name = 'Goalkeeper'},
                    [pscustomobject]@{id = 2; name = 'Defender'}
                )
            }
            $Result = Get-FplClubId

            $Result[1] | Should -Be 'Goalkeeper'
            $Result[2] | Should -Be 'Defender'
        }
    }
}
