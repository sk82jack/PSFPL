Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Invoke-FplTransfer' {
        BeforeAll {
            $Sterling = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 8
                PlayerId       = 270
                Name           = 'Sterling'
                Position       = 'Midfielder'
                IsSub          = $false
                SellingPrice   = 11.2
            }
            $Son = [PSCustomObject]@{
                PSTypeName     = 'FplLineup'
                PositionNumber = 9
                PlayerId       = 367
                Name           = 'Son'
                Position       = 'Midfielder'
                IsSub          = $false
                SellingPrice   = 7.6
            }
            $Hazard = [PSCustomObject]@{
                PSTypeName = 'FplPlayer'
                PlayerId   = 122
                Name       = 'Hazard'
                Position   = 'Midfielder'
                Price      = 11.1
            }
            $Robertson = [PSCustomObject]@{
                PSTypeName = 'FplPlayer'
                PlayerId   = 247
                Name       = 'Robertson'
                Position   = 'Defender'
                Price      = 6.8
            }
            Mock Get-Credential {
                $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                [Management.Automation.PSCredential]::new('UserName', $Password)
            }
            Mock Connect-Fpl {
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                    TeamID     = 12345
                    CurrentGW  = 33
                }
            }
            Mock Get-FplPlayer {}
            Mock Get-FplLineup {$Sterling, $Son}
            Mock Find-FplPlayer {
                $PlayerTransform
            }
            Mock Invoke-RestMethod {}
            Mock Write-Host {}
            Mock Read-FplYesNoPrompt {0}
        }
        It 'throws if you provide a different number of players in/out' {
            $ExpectedMessage = 'You must provide the same number of players coming into the starting lineup as there are players going out.'
            {Invoke-FplTransfer -PlayersIn $Hazard, $Robertson -PlayersOut $Sterling} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'authenticates if not already authenticated' {
            Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction 'SilentlyContinue'
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -Force -WarningAction SilentlyContinue
            Assert-MockCalled Connect-Fpl -Times 1 -Scope 'It'
        }
        It 'does not authenticate if already authenticated' {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                TeamID     = 12345
                CurrentGW  = 33
            }
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -Force
            Assert-MockCalled Connect-Fpl -Times 0 -Scope 'It'
        }
        It 'throws if a player being transferred in is already in your team' {
            $ExpectedMessage = 'The player "Son" is already in your team'
            {Invoke-FplTransfer -PlayersIn $Son -PlayersOut $Sterling -Force} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'converts the player objects into JSON correctly' {
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -Force
            Assert-MockCalled Invoke-RestMethod -Times 1 -Scope 'It' -ParameterFilter {
                $Body -eq @'
{
    "confirmed":  false,
    "freehit":  false,
    "transfers":  [
                      {
                          "selling_price":  112,
                          "element_in":  122,
                          "element_out":  270,
                          "purchase_price":  111
                      }
                  ],
    "wildcard":  false,
    "event":  34,
    "entry":  12345
}
'@
            }
        }
        It 'converts multple player objects into JSON correctly' {
            Invoke-FplTransfer -PlayersIn $Hazard, $Robertson -PlayersOut $Sterling, $Son -Force
            Assert-MockCalled Invoke-RestMethod -Times 1 -Scope 'It' -ParameterFilter {
                $Body -eq @'
{
    "confirmed":  false,
    "freehit":  false,
    "transfers":  [
                      {
                          "selling_price":  112,
                          "element_in":  122,
                          "element_out":  270,
                          "purchase_price":  111
                      },
                      {
                          "selling_price":  76,
                          "element_in":  247,
                          "element_out":  367,
                          "purchase_price":  68
                      }
                  ],
    "wildcard":  false,
    "event":  34,
    "entry":  12345
}
'@
            }
        }
        It 'processes a wildcard activation properly' {
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -ActivateChip 'WildCard' -Force
            Assert-MockCalled Invoke-RestMethod -Times 1 -Scope 'It' -ParameterFilter {
                ($Body | ConvertFrom-Json).wildcard -eq $true
            }
        }
        It 'processes a freehit activation properly' {
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -ActivateChip 'FreeHit' -Force
            Assert-MockCalled Invoke-RestMethod -Times 1 -Scope 'It' -ParameterFilter {
                ($Body | ConvertFrom-Json).freehit -eq $true
            }
        }
        It 'resends the body with confirmation' {
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -Force
            Assert-MockCalled Invoke-RestMethod -Times 1 -Scope 'It' -ParameterFilter {
                ($Body | ConvertFrom-Json).confirmed -eq $true
            }
        }
        It 'outputs confirmation to the host if not using force' {
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling
            Assert-MockCalled Write-Host -Exactly 5 -Scope 'It'
        }
        It 'exits early if you answer no to the confirmation prompt' {
            Mock Read-FplYesNoPrompt {1}
            Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling
            Assert-MockCalled Invoke-RestMethod -Times 0 -Scope 'It' -ParameterFilter {
                ($Body | ConvertFrom-Json).confirmed -eq $true
            }
        }
        It 'catches an API error and throws a PSFPL error' {
            Mock Invoke-RestMethod {throw} -ParameterFilter {
                ($Body | ConvertFrom-Json).confirmed -eq $false
            }
            Mock Get-ErrorResponsePayload {}
            Mock Write-FplError {throw 'Mocked error'}

            {Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Sterling -Force} | Should -Throw -ExpectedMessage 'Mocked error'
            Assert-MockCalled Invoke-RestMethod -Times 1 -Scope 'It' -ParameterFilter {
                ($Body | ConvertFrom-Json).confirmed -eq $false
            }
            Assert-MockCalled Get-ErrorResponsePayload -Times 1 -Scope 'It'
            Assert-MockCalled Write-FplError -Times 1 -Scope 'It'
        }
    }
}
