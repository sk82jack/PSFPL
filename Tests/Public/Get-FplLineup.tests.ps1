Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplLineup' {
        BeforeAll {
            Mock Write-Warning {}
            Mock Get-Credential {
                $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                [Management.Automation.PSCredential]::new('UserName', $Password)
            }
            Mock Connect-Fpl {
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                    CsrfToken  = 'csrftoken'
                    TeamID     = 12345
                }
            }
            Mock Invoke-RestMethod {
                [PSCustomobject]@{
                    Picks = $true
                }
            }
            Mock ConvertTo-FplObject {}
        }
        Context 'Authenticated' {
            BeforeAll {
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                    CsrfToken  = 'csrftoken'
                    TeamID     = 67890
                }
            }
            AfterAll {
                Remove-Variable -Name 'FplSessionData' -Scope 'Script'
            }
            It 'does not try to authenticate' {
                Get-FplLineup
                Assert-MockCalled Connect-Fpl -Times 0 -Scope 'It'
            }
            It 'gets the lineup of the logged in players team' {
                Get-FplLineup
                Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/drf/my-team/67890/'
                }
            }
        }
        Context 'Not authenticated' {
            AfterEach {
                Remove-Variable -Name 'FplSessionData' -Scope 'Script'
            }
            It 'authenticates to get your team ID' {
                Get-FplLineup
                Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/drf/my-team/12345/'
                }
            }
        }
    }
}
