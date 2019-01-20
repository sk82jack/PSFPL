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
                    id           = 4
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
                $Result.psobject.properties.Name | Should -Be @('WebName', 'ElementType', 'Club', 'NowCost', 'PlayerId', 'Position', 'ClubId', 'Price')
            }
            It 'Converts element type to position' {
                $Result.Position | Should -Be 'Defender'
            }
            It 'Converts team ID to club name' {
                $Result.Club | Should -Be 'Arsenal'
            }
            It 'Converts ID to Player ID' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.PlayerId | Should -Be 4
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
            It 'renames the Id property to Gameweek' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.Gameweek | Should -BeExactly 1
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
                    id            = 3
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
            It 'Converts ID to Fixture ID' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.FixtureId | Should -Be 3
            }
        }
        Context 'FplLeagueTable type' {
            BeforeAll {
                $Object = @(
                    [PSCustomObject]@{
                        league    = [PSCustomObject]@{
                            name = 'MyCustomLeague'
                        }
                        standings = [PSCustomObject]@{
                            has_next = $false
                            results  = [PSCustomObject]@{
                                league = 12345
                                entry  = 54321
                            }
                        }
                    },
                    [PSCustomObject]@{
                        league    = [PSCustomObject]@{
                            name = 'MyCustomLeague'
                        }
                        standings = [PSCustomObject]@{
                            has_next = $false
                            results  = [PSCustomObject]@{
                                league = 12345
                                entry  = 65432
                            }
                        }
                    }
                )

                $Results = ConvertTo-FplObject -InputObject $Object -Type 'FplLeagueTable'
            }
            It 'adds the LeagueName property' {
                $Results | Foreach-Object {$_.LeagueName | Should -Be 'MyCustomLeague'}
            }
            It 'renames the League property to LeagueId' {
                $Results | Foreach-Object {$_.League | Should -BeNullOrEmpty}
                $Results.LeagueId | Should -Contain 12345
            }
            It 'renames the Team property to TeamId' {
                $Results | Foreach-Object {$_.Team | Should -BeNullOrEmpty}
                $Results.TeamId | Should -Be 54321, 65432
            }
        }
        Context 'FplTeam type' {
            BeforeAll {
                Mock Get-FplClubId {
                    @{
                        6 = 'Chelsea'
                    }
                }
                $Object = [PSCustomObject]@{
                    bank          = 13
                    value         = 1013
                    favouriteteam = 6
                    id            = 123456
                    player        = 987654321
                }
                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplTeam'
            }
            It 'divides the bank property by 10' {
                $Result.Bank | Should -Be 1.3
            }
            It 'divides the value property by 10' {
                $Result.Value | Should -Be 101.3
            }
            It 'replaces favourite team ID with name' {
                $Result.FavouriteClub | Should -Be 'Chelsea'
            }
            It 'renames the Id property to TeamId' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.TeamId | Should -Be 123456
            }
            It 'renames the Player property to PlayerId' {
                $Result.Player | Should -BeNullOrEmpty
                $Result.PlayerId | Should -Be 987654321
            }
        }
        Context 'FplLeague' {
            BeforeAll {
                $Object = [PSCustomObject]@{
                    classic = [PSCustomObject]@{
                        Name        = 'Classic League'
                        league_type = 'c'
                        _scoring    = 'c'
                        id          = 1
                    }
                    h2h     = @(
                        [PSCustomObject]@{
                            Name = 'cup'
                            id   = 2
                        },
                        [PSCustomObject]@{
                            Name        = 'H2H League'
                            league_type = 's'
                            _scoring    = 'h'
                            id          = 3
                        },
                        [PSCustomObject]@{
                            Name        = 'Classic League 2'
                            league_type = 'x'
                            _scoring    = 'c'
                            id          = 4
                        }
                    )
                }

                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplLeague'
            }
            It 'outputs an FPLLeague object' {
                $Result[0].PSTypeNames | Should -Contain 'FplLeague'
            }
            It 'adds the classic and h2h leagues together leaving out the cup' {
                $Result.Name | Should -Be 'Classic League', 'H2H League', 'Classic League 2'
            }
            It 'converts the LeagueType parameter' {
                $Result.LeagueType | Should -Be 'Public', 'Global', 'Private'
            }
            It 'converts the Scoring parameter' {
                $Result.Scoring | Should -Be 'Classic', 'H2H', 'Classic'
            }
            It 'Converts ID to League ID' {
                $Result.foreach{$_.Id | Should -BeNullOrEmpty}
                $Result.LeagueId | Should -Be 1, 3, 4
            }
        }
    }
}
