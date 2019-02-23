Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Set-FplLineupCaptain' {
        BeforeAll {
            $Lineup = @(
                [PSCustomObject]@{
                    PositionNumber = 1
                    PlayerId       = 400
                    WebName        = 'Fabianski'
                    Position       = 'GoalKeeper'
                    IsCaptain      = $true
                    IsViceCaptain  = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 2
                    PlayerId       = 335
                    WebName        = 'Bednarek'
                    Position       = 'Defender'
                    IsCaptain      = $false
                    IsViceCaptain  = $true
                },
                [PSCustomObject]@{
                    PositionNumber = 3
                    PlayerId       = 427
                    WebName        = 'Bennett'
                    Position       = 'Defender'
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                },
                [PSCustomObject]@{
                    PositionNumber = 15
                    PlayerId       = 409
                    WebName        = 'Diop'
                    Position       = 'Defender'
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                    IsSub          = $true
                }
            )
        }
        BeforeEach {
            $Params = @{
                Lineup = $Lineup
            }
        }
        It 'sets a new captain' {
            $Params['Captain'] = 'Bennett'
            $Result = Set-FplLineupCaptain @Params
            $Result.Where{$_.IsCaptain}.WebName | Should -Be 'Bennett'
        }
        It 'sets a new vice captain' {
            $Params['ViceCaptain'] = 'Bennett'
            $Result = Set-FplLineupCaptain @Params
            $Result.Where{$_.IsViceCaptain}.WebName | Should -Be 'Bennett'
        }
        It 'sets a new captain and a new vice captain' {
            $Params['Captain'] = 'Bennett'
            $Params['ViceCaptain'] = 'Fabianski'
            $Result = Set-FplLineupCaptain @Params
            $Result.Where{$_.IsCaptain}.WebName | Should -Be 'Bennett'
            $Result.Where{$_.IsViceCaptain}.WebName | Should -Be 'Fabianski'
        }
        It 'errors if a substitute is set as the new captain' {
            $Params['Captain'] = 'Diop'
            {Set-FplLineupCaptain @Params} | Should -Throw
        }
        It 'errors if a substitute is set as the new vice captain' {
            $Params['ViceCaptain'] = 'Diop'
            {Set-FplLineupCaptain @Params} | Should -Throw
        }
    }
}
