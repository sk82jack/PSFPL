Import-Module $ENV:BHPSModuleManifest -Force
Describe 'ConvertTo-FplObject' {
    InModuleScope 'PSFPL' {
        Context 'FplPlayer type' {
            BeforeAll {
                $Object = [PSCustomObject]@{
                    web_name     = 'BellerÃ­n'
                    element_type = 3
                    team         = 1
                    now_cost     = 58
                }
                Mock Get-FplElementType {
                    @{
                        1 = 'Goalkeeper'
                        2 = 'Midfielder'
                        3 = 'Defender'
                        4 = 'Forward'
                    }
                }
                Mock Get-FplClubId {
                    @{
                        1 = 'Arsenal'
                        2 = 'Bournemouth'
                    }
                }
                $Result = ConvertTo-FplObject -InputObject $Object -Type FplPlayer
            }
            It 'Converts diacritic characters' {
                $Result.WebName | Should -Be 'Bellerin'
            }
            It 'Outputs an FplPlayer object' {
                $Result.psobject.TypeNames | Should -Contain 'FplPlayer'
            }
            It 'Converts property names to Pascal Case' {
                $Result.psobject.properties.Name | Should -Be @('WebName', 'Position', 'Price', 'Club', 'NowCost', 'ElementType', 'Team')
            }
            It 'Converts element type to position' {
                $Result.Position | Should -Be 'Defender'
            }
            It 'Converts team ID to club name' {
                $Result.Club | Should -Be 'Arsenal'
            }
        }
    }
}
