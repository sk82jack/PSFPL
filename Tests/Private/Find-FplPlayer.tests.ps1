Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Find-FplPlayer' {
        BeforeAll {
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
            $Sterling2 = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 13
                PlayerId       = 578
                Name           = 'Sterling'
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

            $Lineup = $Fabianski, $Bednarek, $Bennett, $AlexanderArnold, $Pogba, $Sane, $Salah,
            $Sterling, $Son, $Rashford, $Jiminez, $Hamer, $Sterling2, $Digne, $Diop
        }
        It 'finds a player based on name' {
            $PlayerTransform = [PSCustomObject]@{
                Name = '^Digne$'
            }
            Find-FplPlayer -PlayerTransform $PlayerTransform -FplPlayerCollection $Lineup | Should -Be $Digne
        }
        It 'finds a player based on player ID' {
            $PlayerTransform = [PSCustomObject]@{
                PlayerID = 484
            }
            Find-FplPlayer -PlayerTransform $PlayerTransform -FplPlayerCollection $Lineup | Should -Be $Digne
        }
        It 'finds a player based on FplLineup type' {
            $PlayerTransform = $Digne
            Find-FplPlayer -PlayerTransform $PlayerTransform -FplPlayerCollection $Lineup | Should -Be $Digne
        }
        It 'throws if multiple matches are found' {
            $PlayerTransform = [PSCustomObject]@{
                Name = '^Sterling$'
            }
            $ExpectedMessage = 'Multiple players found that match "Sterling"'
            {Find-FplPlayer -PlayerTransform $PlayerTransform -FplPlayerCollection $Lineup} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'throws if a player cannot be found in a lineup' {
            $PlayerTransform = [PSCustomObject]@{
                Name = '^Ings$'
            }
            $ExpectedMessage = 'The player "Ings" cannot be found in your team.'
            {Find-FplPlayer -PlayerTransform $PlayerTransform -FplPlayerCollection $Lineup} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'throws if a player cannot be found in general' {
            $PlayerTransform = [PSCustomObject]@{
                Name = '^Ings$'
            }
            $ExpectedMessage = 'The player "Ings" does not exist with the specified properties.'
            {Find-FplPlayer -PlayerTransform $PlayerTransform -FplPlayerCollection $Lineup[0..5]} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
    }
}
