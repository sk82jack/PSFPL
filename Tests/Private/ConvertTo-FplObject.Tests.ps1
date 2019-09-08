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
            It 'outputs an FplPlayer object' {
                $Result.PSTypeNames | Should -Contain 'FplPlayer'
            }
            It 'converts diacritic characters' {
                $Result.Name | Should -Be 'Bellerin'
            }
            It 'converts property names to Pascal Case' {
                $Result.psobject.properties.Name | Should -Be @('WebName', 'ElementType', 'Club', 'NowCost', 'PlayerId', 'Name', 'Position', 'ClubId', 'Price')
            }
            It 'converts element type to position' {
                $Result.Position | Should -Be 'Defender'
            }
            It 'converts team ID to club name' {
                $Result.Club | Should -Be 'Arsenal'
            }
            It 'converts ID to Player ID' {
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
                    chip_plays          = @(
                        [PSCustomObject]@{
                            chip_name  = 'bboost'
                            num_played = 1
                        }
                        [PSCustomObject]@{
                            chip_name  = '3xc'
                            num_played = 2
                        }
                    )
                    MostSelected        = 1
                    MostTransferredIn   = 2
                    TopElement          = 3
                    MostCaptained       = 4
                    MostViceCaptained   = 5
                    TopElementInfo      = [PSCustomObject]@{
                        points = 5
                    }
                }
                Mock Get-FplElementId {
                    @{
                        1 = 'Sterling'
                        2 = 'Puuki'
                        3 = 'Salah'
                        4 = 'Aguero'
                        5 = 'Mane'
                    }
                }
                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplGameweek'
            }
            It 'outputs an FplGameweek object' {
                $Result.PSTypeNames | Should -Contain 'FplGameweek'
            }
            It 'converts "Entry" in a property name to "Team"' {
                $Result.psobject.properties.name | Should -Contain 'AverageTeamScore'
            }
            It 'converts DeadlineTime to a DateTime object' {
                $Result.DeadlineTime | Should -BeOfType [DateTime]
            }
            It 'renames the Id property to Gameweek' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.Gameweek | Should -BeExactly 1
            }
            It 'sets the BenchBoostPlays property' {
                $Result.BenchBoostPlays | Should -Be 1
            }
            It 'sets the TripleCaptainPlays property' {
                $Result.TripleCaptainPlays | Should -Be 2
            }
            It 'converts player ID properties to player names' {
                $Result.MostSelected | Should -Be 'Sterling'
                $Result.MostTransferredIn | Should -Be 'Puuki'
                $Result.TopElement | Should -Be 'Salah'
                $Result.MostCaptained | Should -Be 'Aguero'
                $Result.MostViceCaptained | Should -Be 'Mane'
            }
            It 'sets the TopElementPoints property' {
                $Result.TopElementPoints | Should -Be 5
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
                },
                [PSCustomObject]@{
                    event         = 2
                    deadline_time = $null
                    kickoff_time  = $null
                    gameweek      = $null
                    team_a        = 3
                    team_h        = 4
                    id            = 5
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

                $Result = ConvertTo-FplObject -InputObject $Object[0] -Type 'FplFixture'
            }
            It 'changes "Event" to "Gameweek" in property names' {
                $Result.psobject.properties.Name | Should -Contain 'Gameweek'
                $Result.psobject.properties.Name | Should -Not -Contain 'Event'
            }
            It 'converts DeadlineTime to a DateTime object' {
                $Result.DeadlineTime | Should -BeOfType [DateTime]
            }
            It 'converts KickoffTime to a DateTime object' {
                $Result.KickoffTime | Should -BeOfType [DateTime]
            }
            It 'converts team ID to name' {
                $Result.Stats[0].ClubName | Should -Be 'Leicester'
                $Result.Stats[1].ClubName | Should -Be 'Man Utd'
            }
            It 'flattens the nested stats property' {
                $Result.Stats[0].psobject.Properties.Name | Should -Be  @(
                    'PlayerId',
                    'PlayerName',
                    'StatType',
                    'StatValue',
                    'ClubName'
                )
            }
            It 'converts stats player ID to name' {
                $Result.Stats.PlayerName | Should -Be @(
                    'Vardy',
                    'Shaw',
                    'Pogba'
                )
            }
            It 'removes underscores from stat types' {
                $Result.Stats.StatType | Should -Not -Match '_'
            }
            It 'converts stats club ID to name' {
                $Result.Stats.ClubName | Should -Be @(
                    'Leicester',
                    'Man Utd',
                    'Man Utd'
                )
            }
            It 'converts ID to Fixture ID' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.FixtureId | Should -Be 3
            }
            It 'handles null values for deadline, kickoff and gameweek' {
                $Result = ConvertTo-FplObject -InputObject $Object[1] -Type 'FplFixture'
                $Result.Gameweek, $Result.DeadlineTime, $Result.KickoffTime | ForEach-Object {
                    $_ | Should -Be 'tbc'
                }
            }
        }
        Context 'FplLeagueTable type' {
            BeforeAll {
                $Object = @(
                    [PSCustomObject]@{
                        league    = [PSCustomObject]@{
                            name = 'MyCustomLeague'
                            id   = 12345
                        }
                        standings = [PSCustomObject]@{
                            has_next = $false
                            results  = [PSCustomObject]@{
                                entry = 54321
                            }
                        }
                    },
                    [PSCustomObject]@{
                        league    = [PSCustomObject]@{
                            name = 'MyCustomLeague'
                            id   = 12345
                        }
                        standings = [PSCustomObject]@{
                            has_next = $false
                            results  = [PSCustomObject]@{
                                entry = 65432
                            }
                        }
                    }
                )

                $Results = ConvertTo-FplObject -InputObject $Object -Type 'FplLeagueTable'
            }
            It 'adds the LeagueName property' {
                $Results | ForEach-Object {$_.LeagueName | Should -Be 'MyCustomLeague'}
            }
            It 'adds the LeagueId property' {
                $Results.LeagueId | Should -Contain 12345
            }
            It 'renames the Team property to TeamId' {
                $Results | ForEach-Object {$_.Team | Should -BeNullOrEmpty}
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
                    last_deadline_bank  = 13
                    last_deadline_value = 1013
                    favouriteteam       = 6
                    id                  = 123456
                    joined_time         = '2919-09-08T19:27:35'
                }
                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplTeam'
            }
            It 'divides the LastDeadlineBank property by 10' {
                $Result.LastDeadlineBank | Should -Be 1.3
            }
            It 'divides the LastDeadlineValue property by 10' {
                $Result.LastDeadlineValue | Should -Be 101.3
            }
            It 'replaces favourite team ID with name' {
                $Result.FavouriteClub | Should -Be 'Chelsea'
            }
            It 'renames the Id property to TeamId' {
                $Result.Id | Should -BeNullOrEmpty
                $Result.TeamId | Should -Be 123456
            }
            It 'converts the JoinedTime property to a datetime object' {
                $Result.JoinedTime | Should -BeOfType [datetime]
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
                        created     = '2919-09-08T19:27:35'
                    }
                    h2h     = @(
                        [PSCustomObject]@{
                            Name    = 'cup'
                            id      = 2
                            created = '2919-09-08T19:27:35'
                        },
                        [PSCustomObject]@{
                            Name        = 'H2H League'
                            league_type = 's'
                            _scoring    = 'h'
                            id          = 3
                            created     = '2919-09-08T19:27:35'
                        },
                        [PSCustomObject]@{
                            Name        = 'Classic League 2'
                            league_type = 'x'
                            _scoring    = 'c'
                            id          = 4
                            created     = '2919-09-08T19:27:35'
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
            It 'converts ID to League ID' {
                $Result.foreach{$_.Id | Should -BeNullOrEmpty}
                $Result.LeagueId | Should -Be 1, 3, 4
            }
            It 'converts the Created property to a datetime object' {
                $Result.foreach{$_.Created | Should -BeOfType [datetime]}
            }
        }
        Context 'FplTeamPlayer' {
            BeforeAll {
                $Script:FplSessionData = @{
                    Players = @(
                        [PSCustomObject]@{
                            id = 122
                        }
                        [PSCustomObject]@{
                            id = 115
                        }
                    )
                }
                Mock ConvertTo-FplObject -ParameterFilter {$Type -eq 'FplPlayer'} {
                    @(
                        [PSCustomObject]@{
                            Name           = 'Hazard'
                            PlayerId       = 122
                            Club           = 'Chelsea'
                            Position       = 'Midfielder'
                            GameweekPoints = 8
                        }
                        [PSCustomObject]@{
                            Name           = 'Alonso'
                            PlayerId       = 115
                            Club           = 'Chelsea'
                            Position       = 'Defender'
                            GameweekPoints = 2
                        }
                    )
                }

                $Object = [PSCustomObject]@{
                    element         = 122
                    position        = 1
                    is_captain      = $true
                    is_vice_captain = $false
                    multiplier      = 2
                    news_added      = '2019-09-08T19:27:35'
                },
                [PSCustomObject]@{
                    element         = 115
                    position        = 12
                    is_captain      = $false
                    is_vice_captain = $false
                    multiplier      = 1
                    news_added      = '2019-09-08T19:27:35'
                }

                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplTeamPlayer'
            }
            It 'outputs an FPLTeamPlayer object' {
                $Result[0].PSTypeNames | Should -Contain 'FplTeamPlayer'
            }
            It 'renames the Element property to PlayerId' {
                $Result[0].Element | Should -BeNullOrEmpty
                $Result.PlayerId | Should -Be 122, 115
            }
            It 'sets the PlayingStatus property' {
                $Result[0].PlayingStatus | Should -Be 'Starting'
                $Result[1].PlayingStatus | Should -Be 'Substitute'
            }
            It 'transfers properties from the FplPlayer object' {
                $Result.Name | Should -Be 'Hazard', 'Alonso'
                $Result.Club | Should -Be 'Chelsea', 'Chelsea'
                $Result.Position | Should -Be 'Midfielder', 'Defender'
            }
            It 'calculates captain points for only the captain' {
                $Result.Points | Should -Be 16, 2
            }
            It 'converts the NewsAdded property to a datetime object' {
                $Result.NewsAdded | Foreach-Object {$_ | Should -BeOfType [datetime]}
            }
        }
        Context 'FplLineup' {
            BeforeAll {
                $Script:FplSessionData = @{
                    Players = @(
                        [PSCustomObject]@{
                            id = 122
                        }
                        [PSCustomObject]@{
                            id = 115
                        }
                    )
                }
                Mock ConvertTo-FplObject -ParameterFilter {$Type -eq 'FplPlayer'} {
                    @(
                        [PSCustomObject]@{
                            Name           = 'Hazard'
                            PlayerId       = 122
                            Club           = 'Chelsea'
                            Position       = 'Midfielder'
                            GameweekPoints = 8
                        }
                        [PSCustomObject]@{
                            Name           = 'Alonso'
                            PlayerId       = 115
                            Club           = 'Chelsea'
                            Position       = 'Defender'
                            GameweekPoints = 2
                        }
                    )
                }

                $Object = [PSCustomObject]@{
                    element         = 122
                    position        = 1
                    is_captain      = $true
                    is_vice_captain = $false
                    multiplier      = 2
                    selling_price   = 111
                },
                [PSCustomObject]@{
                    element         = 115
                    position        = 12
                    is_captain      = $false
                    is_vice_captain = $false
                    multiplier      = 1
                    selling_price   = 67
                }

                $Result = ConvertTo-FplObject -InputObject $Object -Type 'FplLineup'
            }
            It 'outputs an FPLLineup object' {
                $Result[0].PSTypeNames | Should -Contain 'FplLineup'
            }
            It 'renames the Element property to PlayerId' {
                $Result[0].Element | Should -BeNullOrEmpty
                $Result.PlayerId | Should -Be 122, 115
            }
            It 'renames the Position property to PositionNumber' {
                $Result[0].Element | Should -BeNullOrEmpty
                $Result.PositionNumber | Should -Be 1, 12
            }
            It 'sets the PlayingStatus property' {
                $Result[0].PlayingStatus | Should -Be 'Starting'
                $Result[1].PlayingStatus | Should -Be 'Substitute'
            }
            It 'transfers properties from the FplPlayer object' {
                $Result.Name | Should -Be 'Hazard', 'Alonso'
                $Result.Club | Should -Be 'Chelsea', 'Chelsea'
                $Result.Position | Should -Be 'Midfielder', 'Defender'
            }
            It 'calculates and sets selling price' {
                $Result.SellingPrice | Should -Be 11.1, 6.7
            }
        }
    }
}
