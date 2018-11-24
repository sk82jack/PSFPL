Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplElementType' {
        BeforeAll {
            Mock Invoke-RestMethod {
                @(
                    [pscustomobject]@{id = 1; singular_name = 'Goalkeeper'},
                    [pscustomobject]@{id = 2; singular_name = 'Defender'}
                )
            }
            $Result = Get-FplElementType
        }
        It 'Parses objects into hashtable' {
            $Result[1] | Should -Be 'Goalkeeper'
            $Result[2] | Should -Be 'Defender'
        }
    }
}
