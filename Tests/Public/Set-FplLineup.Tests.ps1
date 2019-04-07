Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Set-FplLineup' {
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
            Mock Get-Credential {
                $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                [Management.Automation.PSCredential]::new('UserName', $Password)
            }
            Mock Connect-Fpl {
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                    TeamID     = 12345
                }
            }
            Mock Get-FplLineup {
                $Fabianski, $Bednarek, $Bennett, $AlexanderArnold, $Pogba, $Sane, $Salah,
                $Sterling, $Son, $Rashford, $Jiminez, $Hamer, $Ings, $Digne, $Diop
            }
            Mock Find-FplPlayer {
                $PlayerTransform
            }
            Mock Invoke-FplLineupSwap {
                [PSCustomObject]@{
                    PSTypeName     = 'FplLineup'
                    PlayerId       = 335
                    PositionNumber = 4
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                },
                [PSCustomObject]@{
                    PSTypeName     = 'FplLineup'
                    PlayerId       = 484
                    PositionNumber = 14
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                }
            }
            Mock Set-FplLineupCaptain {
                [PSCustomObject]@{
                    PSTypeName     = 'FplLineup'
                    PlayerId       = 335
                    PositionNumber = 4
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                },
                [PSCustomObject]@{
                    PSTypeName     = 'FplLineup'
                    PlayerId       = 484
                    PositionNumber = 14
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                }
            }
            Mock Assert-FplLineup {}
            Mock Invoke-RestMethod {}
        }
        AfterEach {
            Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction 'SilentlyContinue'
        }
        It 'errors if you do not provide an argument to any parameters' {
            {Set-FplLineup} | Should -Throw
        }
        It 'errors if you provide a different number of players in vs out' {
            {Set-FplLineup -PlayersIn $Son, $Rashford -PlayersOut $Pogba} | Should -Throw
        }
        It 'runs Connect-Fpl if not authenticated' {
            Set-FplLineup -PlayersIn $Sterling -PlayersOut $Digne -WarningAction 'SilentlyContinue'
            Assert-MockCalled Connect-Fpl -Exactly 1 -Scope 'It'
        }
        It "doesn't run Connect-Fpl if authenticated" {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            Set-FplLineup -PlayersIn $Sterling -PlayersOut $Digne
            Assert-MockCalled Connect-Fpl -Exactly 0 -Scope 'It'
        }
        It 'errors if you supply a name that is not in your team' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            {Set-FplLineup -PlayersIn 'WrongPlayer' -PlayersOut $Digne} | Should -Throw
            {Set-FplLineup -PlayersIn $Digne -PlayersOut 'WrongPlayer'} | Should -Throw
            {Set-FplLineup -PlayersIn $Sterling -PlayersOut $Digne -Captain 'WrongPlayer'} | Should -Throw
            {Set-FplLineup -PlayersIn $Sterling -PlayersOut $Digne -ViceCaptain 'WrongPlayer'} | Should -Throw
        }
        It 'runs Invoke-FplLineupSwap if we provide players in and out' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            Set-FplLineup -PlayersIn $Sterling -PlayersOut $Digne
            Assert-MockCalled Invoke-FplLineupSwap -Exactly 1 -Scope 'It'
        }
        It 'does not run Invoke-FplLineupSwap if we just change captains' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            Set-FplLineup -Captain $Sterling
            Set-FplLineup -ViceCaptain $Sterling
            Assert-MockCalled Invoke-FplLineupSwap -Exactly 0 -Scope 'It'
        }
        It 'runs Invoke-RestMethod with the right arguments' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
                CsrfToken  = 'csrftoken'
            }
            Set-FplLineup -PlayersIn $Sterling -PlayersOut $Digne
            Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                $Object = $Body | ConvertFrom-Json
                $Object.picks.Foreach{
                    $_.element -in 335, 484 -and
                    $_.position -in 4, 14 -and
                    $_.is_captain -eq $false -and
                    $_.is_vice_captain -eq $false
                } -notcontains $false -and
                $Uri -eq 'https://fantasy.premierleague.com/drf/my-team/12345/' -and
                $Headers['X-CSRFToken'] -eq 'csrftoken'
            }
        }
        It 'catches, formats and re-throws errors from the API' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
                CsrfToken  = 'csrftoken'
            }
            Mock Invoke-RestMethod {
                throw
            }
            Mock Get-ErrorResponsePayload {
                '{"details":{"non_field_errors":["TXFER_ET_BAD_COUNT::You need to select between 1 and 1 Goalkeepers. 2 were selected."],"errors":[{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]}}'
            }
            Mock Write-FplError {
                Write-Error -Message 'You need to select between 1 and 1 Goalkeepers. 2 were selected.' -ErrorAction 'Stop'
            }
            $ExpectedMessage = 'You need to select between 1 and 1 Goalkeepers. 2 were selected.'
            {Set-FplLineup -Captain $Sterling} | Should -Throw -ExpectedMessage $ExpectedMessage
            Assert-MockCalled Invoke-RestMethod -Scope 'It'
            Assert-MockCalled Get-ErrorResponsePayload -Scope 'It'
            Assert-MockCalled Write-FplError -Scope 'It'
        }
    }
}
