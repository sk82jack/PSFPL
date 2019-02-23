Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Invoke-FplLineupSwap' {
        BeforeEach {
            $Lineup = @(
                [PSCustomObject]@{
                    PositionNumber = 1
                    PlayerId       = 400
                    WebName        = 'Fabianski'
                    Position       = 'GoalKeeper'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 2
                    PlayerId       = 335
                    WebName        = 'Bednarek'
                    Position       = 'Defender'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 3
                    PlayerId       = 427
                    WebName        = 'Bennett'
                    Position       = 'Defender'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 4
                    PlayerId       = 245
                    WebName        = 'Alexander-Arnold'
                    Position       = 'Defender'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 5
                    PlayerId       = 302
                    WebName        = 'Pogba'
                    Position       = 'Midfielder'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 6
                    PlayerId       = 275
                    WebName        = 'Sane'
                    Position       = 'Midfielder'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 7
                    PlayerId       = 253
                    WebName        = 'Salah'
                    Position       = 'Midfielder'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 8
                    PlayerId       = 270
                    WebName        = 'Sterling'
                    Position       = 'Midfielder'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 9
                    PlayerId       = 367
                    WebName        = 'Son'
                    Position       = 'Midfielder'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 10
                    PlayerId       = 305
                    WebName        = 'Rashford'
                    Position       = 'Forward'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 11
                    PlayerId       = 437
                    WebName        = 'Jimenez'
                    Position       = 'Forward'
                    IsSub          = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 12
                    PlayerId       = 190
                    WebName        = 'Hamer'
                    Position       = 'Goalkeeper'
                    IsSub          = $true
                },
                [PSCustomObject]@{
                    PositionNumber = 13
                    PlayerId       = 258
                    WebName        = 'Ings'
                    Position       = 'Forward'
                    IsSub          = $true
                },
                [PSCustomObject]@{
                    PositionNumber = 14
                    PlayerId       = 484
                    WebName        = 'Digne'
                    Position       = 'Defender'
                    IsSub          = $true
                },
                [PSCustomObject]@{
                    PositionNumber = 15
                    PlayerId       = 409
                    WebName        = 'Diop'
                    Position       = 'Defender'
                    IsSub          = $true
                }
            )
            $Params = @{
                Lineup = $Lineup
            }
        }
        It 'swaps a single player of the same position' {
            $Params['PlayersIn'] = 'Ings'
            $Params['PlayersOut'] = 'Rashford'
            $Result = Invoke-FplLineupSwap @Params
            $Result[9].WebName | Should -Be 'Ings'
            $Result[12].WebName | Should -Be 'Rashford'
        }
        It 'swaps multiple players of the same positions' {
            $Params['PlayersIn'] = 'Ings', 'Diop', 'Digne'
            $Params['PlayersOut'] = 'Rashford', 'Bednarek', 'Bennett'
            $Result = Invoke-FplLineupSwap @Params
            $Result[9].WebName | Should -Be 'Ings'
            $Result[12].WebName | Should -Be 'Rashford'
            $Result[1].WebName | Should -Be 'Diop'
            $Result[14].WebName | Should -Be 'Bednarek'
            $Result[2].WebName | Should -Be 'Digne'
            $Result[13].WebName | Should -Be 'Bennett'
        }
        It 'swaps a single player of a different type' {
            $Params['PlayersIn'] = 'Ings'
            $Params['PlayersOut'] = 'Bennett'
            $Result = Invoke-FplLineupSwap @Params
            $Result[8].WebName | Should -Be 'Ings'
            $Result[12].WebName | Should -Be 'Bennett'
        }
        It 'swaps multiple players of different types' {
            $Params['PlayersIn'] = 'Ings', 'Diop', 'Digne'
            $Params['PlayersOut'] = 'Son', 'Rashford', 'Sane'
            $Result = Invoke-FplLineupSwap @Params
            $Result[9].WebName | Should -Be 'Ings'
            $Result[12].WebName | Should -Be 'Son'
            $Result[4].WebName | Should -Be 'Diop'
            $Result[14].WebName | Should -Be 'Rashford'
            $Result[5].WebName | Should -Be 'Digne'
            $Result[13].WebName | Should -Be 'Sane'
        }
        It 'sorts the new starting XI' {
            $Params['PlayersIn'] = 'Ings', 'Diop', 'Digne'
            $Params['PlayersOut'] = 'Son', 'Rashford', 'Sane'
            $Result = Invoke-FplLineupSwap @Params
            $Result.PositionNumber | Should -Be (1..15)
        }
    }
}