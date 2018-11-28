Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'ConvertTo-FplObject' {
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
            It 'Outputs an FplPlayer object' {
                $Result.PSTypeNames | Should -Contain 'FplPlayer'
            }
            It 'Converts diacritic characters' {
                $Result.WebName | Should -Be 'Bellerin'
            }
            It 'Converts property names to Pascal Case' {
                $Result.psobject.properties.Name | Should -Be @('WebName', 'ElementType', 'Club', 'NowCost', 'Position', 'ClubId', 'Price')
            }
            It 'Converts element type to position' {
                $Result.Position | Should -Be 'Defender'
            }
            It 'Converts team ID to club name' {
                $Result.Club | Should -Be 'Arsenal'
            }
        }
        Context 'FplGameweek type' {
            BeforeAll {
                $Object = [PSCustomObject]@{
                    id                  = 1
                    deadline_time       = '08/10/2018 18:00:00'
                    average_entry_score = 53
                }
                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplGameweek'
            }
            It 'Outputs an FplGameweek object' {
                $Result.PSTypeNames | Should -Contain 'FplGameweek'
            }
            It 'Converts "Entry" in a property name to "Team"' {
                $Result.psobject.properties.name | Should -Contain 'AverageTeamScore'
            }
            It 'Converts DeadlineTime to a DateTime object' {
                $Result.DeadlineTime | Should -BeOfType [DateTime]
            }
        }
    }
}
