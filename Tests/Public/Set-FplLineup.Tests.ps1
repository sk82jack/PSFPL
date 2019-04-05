Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Set-FplLineup' {
        BeforeAll {
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
                [PSCustomObject]@{
                    Name       = 'Sterling'
                    IsCaptain     = $false
                    IsViceCaptain = $false
                },
                [PSCustomObject]@{
                    Name       = 'Digne'
                    IsCaptain     = $false
                    IsViceCaptain = $false
                }
            }
            Mock Invoke-FplLineupSwap {
                [PSCustomObject]@{
                    PlayerId       = 335
                    PositionNumber = 4
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                },
                [PSCustomObject]@{
                    PlayerId       = 484
                    PositionNumber = 14
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                }
            }
            Mock Set-FplLineupCaptain {
                [PSCustomObject]@{
                    PlayerId       = 335
                    PositionNumber = 4
                    IsCaptain      = $false
                    IsViceCaptain  = $false
                },
                [PSCustomObject]@{
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
            {Set-FplLineup -PlayersIn 'Son', 'Rashford' -PlayersOut 'Pogba'} | Should -Throw
        }
        It 'runs Connect-Fpl if not authenticated' {
            Set-FplLineup -PlayersIn 'Sterling' -PlayersOut 'Digne' -WarningAction 'SilentlyContinue'
            Assert-MockCalled Connect-Fpl -Exactly 1 -Scope 'It'
        }
        It "doesn't run Connect-Fpl if authenticated" {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            Set-FplLineup -PlayersIn 'Sterling' -PlayersOut 'Digne'
            Assert-MockCalled Connect-Fpl -Exactly 0 -Scope 'It'
        }
        It 'errors if you supply a name that is not in your team' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            {Set-FplLineup -PlayersIn 'WrongPlayer' -PlayersOut 'Digne'} | Should -Throw
            {Set-FplLineup -PlayersIn 'Digne' -PlayersOut 'WrongPlayer'} | Should -Throw
            {Set-FplLineup -PlayersIn 'Sterling' -PlayersOut 'Digne' -Captain 'WrongPlayer'} | Should -Throw
            {Set-FplLineup -PlayersIn 'Sterling' -PlayersOut 'Digne' -ViceCaptain 'WrongPlayer'} | Should -Throw
        }
        It 'runs Invoke-FplLineupSwap if we provide players in and out' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            Set-FplLineup -PlayersIn 'Sterling' -PlayersOut 'Digne'
            Assert-MockCalled Invoke-FplLineupSwap -Exactly 1 -Scope 'It'
        }
        It 'does not run Invoke-FplLineupSwap if we just change captains' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
            }
            Set-FplLineup -Captain 'Sterling'
            Set-FplLineup -ViceCaptain 'Sterling'
            Assert-MockCalled Invoke-FplLineupSwap -Exactly 0 -Scope 'It'
        }
        It 'runs Invoke-RestMethod with the right arguments' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
                CsrfToken = 'csrftoken'
            }
            Set-FplLineup -PlayersIn 'Sterling' -PlayersOut 'Digne'
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
    }
}
