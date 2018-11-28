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
        Context 'FplFixture type' {
            BeforeAll {
                $Object = [PSCustomObject]@{
                    event         = 1
                    deadline_time = '2018-08-10T18:00:00Z'
                    kickoff_time  = '2018-08-10T19:00:00Z'
                    team_a        = 1
                    team_h        = 2
                    stats         = @(
                        [pscustomobject]@{
                            goals_scored = [pscustomobject]@{
                                a = @(
                                    [pscustomobject]@{
                                        value   = 1
                                        element = 234
                                    }
                                )
                                h = @(
                                    [pscustomobject]@{
                                        value   = 1
                                        element = 286
                                    },
                                    [pscustomobject]@{
                                        value   = 1
                                        element = 302
                                    }
                                )
                            }
                        }
                    )
                }

                Mock Get-FplClubId {
                    @{
                        1 = 'Leicester'
                        2 = 'Man Utd'
                    }
                }

                Mock Get-FplElementId {
                    @{
                        234 = 'Vardy'
                        286 = 'Shaw'
                        302 = 'Pogba'
                    }
                }

                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplFixture'
            }
            It 'Changes "Event" to "Gameweek" in property names' {
                $Result.psobject.properties.Name | Should -Contain 'Gameweek'
                $Result.psobject.properties.Name | Should -Not -Contain 'Event'
            }
            It 'Converts DeadlineTime to a DateTime object' {
                $Result.DeadlineTime | Should -BeOfType [DateTime]
            }
            It 'Converts KickoffTime to a DateTime object' {
                $Result.KickoffTime | Should -BeOfType [DateTime]
            }
            It 'Converts team ID to name' {
                $Result.Stats[0].ClubName | Should -Be 'Leicester'
                $Result.Stats[1].ClubName | Should -Be 'Man Utd'
            }
            It 'Flattens the nested stats property' {
                $Result.Stats[0].psobject.Properties.Name | Should -Be  @(
                    'PlayerId',
                    'PlayerName',
                    'StatType',
                    'StatValue',
                    'ClubName'
                )
            }
            It 'Converts stats player ID to name' {
                $Result.Stats.PlayerName | Should -Be @(
                    'Vardy',
                    'Shaw',
                    'Pogba'
                )
            }
            It 'Removes underscores from stat types' {
                $Result.Stats.StatType | Should -Not -Match '_'
            }
            It 'Converts stats club ID to name' {
                $Result.Stats.ClubName | Should -Be @(
                    'Leicester',
                    'Man Utd',
                    'Man Utd'
                )
            }
        }
    }
}
