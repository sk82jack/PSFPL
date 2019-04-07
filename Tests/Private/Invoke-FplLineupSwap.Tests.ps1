Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Invoke-FplLineupSwap' {
        BeforeEach {
            $Fabianski = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 1
                PlayerId       = 400
                Name           = 'Fabianski'
                Position       = 'GoalKeeper'
                IsSub          = $false
            }
            $Bednarek = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 2
                PlayerId       = 335
                Name           = 'Bednarek'
                Position       = 'Defender'
                IsSub          = $false
            }
            $Bennett = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 3
                PlayerId       = 427
                Name           = 'Bennett'
                Position       = 'Defender'
                IsSub          = $false
            }
            $AlexanderArnold = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 4
                PlayerId       = 245
                Name           = 'Alexander-Arnold'
                Position       = 'Defender'
                IsSub          = $false
            }
            $Pogba = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 5
                PlayerId       = 302
                Name           = 'Pogba'
                Position       = 'Midfielder'
                IsSub          = $false
            }
            $Sane = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 6
                PlayerId       = 275
                Name           = 'Sane'
                Position       = 'Midfielder'
                IsSub          = $false
            }
            $Salah = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 7
                PlayerId       = 253
                Name           = 'Salah'
                Position       = 'Midfielder'
                IsSub          = $false
            }
            $Sterling = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 8
                PlayerId       = 270
                Name           = 'Sterling'
                Position       = 'Midfielder'
                IsSub          = $false
            }
            $Son = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 9
                PlayerId       = 367
                Name           = 'Son'
                Position       = 'Midfielder'
                IsSub          = $false
            }
            $Rashford = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 10
                PlayerId       = 305
                Name           = 'Rashford'
                Position       = 'Forward'
                IsSub          = $false
            }
            $Jiminez = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 11
                PlayerId       = 437
                Name           = 'Jimenez'
                Position       = 'Forward'
                IsSub          = $false
            }
            $Hamer = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 12
                PlayerId       = 190
                Name           = 'Hamer'
                Position       = 'Goalkeeper'
                IsSub          = $true
            }
            $Ings = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 13
                PlayerId       = 258
                Name           = 'Ings'
                Position       = 'Forward'
                IsSub          = $true
            }
            $Digne = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 14
                PlayerId       = 484
                Name           = 'Digne'
                Position       = 'Defender'
                IsSub          = $true
            }
            $Diop = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 15
                PlayerId       = 409
                Name           = 'Diop'
                Position       = 'Defender'
                IsSub          = $true
            }
            $Params = @{
                Lineup = $Fabianski, $Bednarek, $Bennett, $AlexanderArnold, $Pogba, $Sane, $Salah,
                $Sterling, $Son, $Rashford, $Jiminez, $Hamer, $Ings, $Digne, $Diop
            }
        }
        It 'swaps a single player of the same position' {
            $Params['PlayersIn'] = $Ings
            $Params['PlayersOut'] = $Rashford
            $Result = Invoke-FplLineupSwap @Params
            $Result[9].Name | Should -Be 'Ings'
            $Result[12].Name | Should -Be 'Rashford'
        }
        It 'swaps multiple players of the same positions' {
            $Params['PlayersIn'] = $Ings, $Diop, $Digne
            $Params['PlayersOut'] = $Rashford, $Bednarek, $Bennett
            $Result = Invoke-FplLineupSwap @Params
            $Result[9].Name | Should -Be 'Ings'
            $Result[12].Name | Should -Be 'Rashford'
            $Result[1].Name | Should -Be 'Diop'
            $Result[14].Name | Should -Be 'Bednarek'
            $Result[2].Name | Should -Be 'Digne'
            $Result[13].Name | Should -Be 'Bennett'
        }
        It 'swaps a single player of a different type' {
            $Params['PlayersIn'] = $Ings
            $Params['PlayersOut'] = $Bennett
            $Result = Invoke-FplLineupSwap @Params
            $Result[8].Name | Should -Be 'Ings'
            $Result[12].Name | Should -Be 'Bennett'
        }
        It 'swaps multiple players of different types' {
            $Params['PlayersIn'] = $Ings, $Diop, $Digne
            $Params['PlayersOut'] = $Son, $Rashford, $Sane
            $Result = Invoke-FplLineupSwap @Params
            $Result[9].Name | Should -Be 'Ings'
            $Result[12].Name | Should -Be 'Son'
            $Result[4].Name | Should -Be 'Diop'
            $Result[14].Name | Should -Be 'Rashford'
            $Result[5].Name | Should -Be 'Digne'
            $Result[13].Name | Should -Be 'Sane'
        }
        It 'sorts the new starting XI' {
            $Params['PlayersIn'] = $Ings, $Diop, $Digne
            $Params['PlayersOut'] = $Son, $Rashford, $Sane
            $Result = Invoke-FplLineupSwap @Params
            $Result.PositionNumber | Should -Be (1..15)
        }
    }
}
