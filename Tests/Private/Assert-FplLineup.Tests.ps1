Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Assert-FplLineup' {
        BeforeAll {
            $NoKeepers = @()
            $TwoKeepers = @(
                [PSCustomObject]@{
                    Position = 'GoalKeeper'
                },
                [PSCustomObject]@{
                    Position = 'GoalKeeper'
                }
            )
            $NoDefenders = @(
                [PSCustomObject]@{
                    Position = 'GoalKeeper'
                }
            )
            $NoMidfielders = @(
                [PSCustomObject]@{
                    Position = 'GoalKeeper'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                }
            )
            $NoForwards = @(
                [PSCustomObject]@{
                    Position = 'GoalKeeper'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Midfielder'
                },
                [PSCustomObject]@{
                    Position = 'Midfielder'
                }
            )
            $GoodLineup = @(
                [PSCustomObject]@{
                    Position = 'GoalKeeper'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Defender'
                },
                [PSCustomObject]@{
                    Position = 'Midfielder'
                },
                [PSCustomObject]@{
                    Position = 'Midfielder'
                },
                [PSCustomObject]@{
                    Position = 'Forward'
                }
            )
        }
        It 'errors if there are no goalkeepers' {
            {Assert-FplLineup -Lineup $NoKeepers} | Should -Throw
        }
        It 'errors if there are 2 goalkeepers' {
            {Assert-FplLineup -Lineup $TwoKeepers} | Should -Throw
        }
        It 'errors if there are less than 3 defenders' {
            {Assert-FplLineup -Lineup $NoDefenders} | Should -Throw
        }
        It 'errors if there are less than 2 midfielders' {
            {Assert-FplLineup -Lineup $NoMidfielders} | Should -Throw
        }
        It 'errors if there are no forwards' {
            {Assert-FplLineup -Lineup $NoForwards} | Should -Throw
        }
        It 'does not error if a there is a valid number of players per position' {
            {Assert-FplLineup -Lineup $GoodLineup} | Should -Not -Throw
        }
    }
}
