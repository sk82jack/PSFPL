Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplTeam' {
        Context 'TeamId passed' {
            BeforeAll {
                Mock Invoke-RestMethod {
                    [PSCustomObject]@{
                        entry = $true
                    }
                }
                Mock ConvertTo-FplObject {}
            }
            It 'passes the TeamId onto Invoke-RestMethod' {
                $Results = Get-FplTeam -TeamId 123456
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/drf/entry/123456/'} -Scope 'It'
            }
            It 'accepts pipeline input' {
                $Results = 123456 | Get-FplTeam
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/drf/entry/123456/'} -Scope 'It'
            }
        }
        Context 'No TeamID whilst not logged in' {
            BeforeAll {
                Mock Invoke-RestMethod {}
                Mock Get-Credential {
                    $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                    [Management.Automation.PSCredential]::new('UserName', $Password)
                }
                Mock Connect-Fpl {}
                Mock Get-FplUserTeam {'12345'}
            }
            It 'returns a warning' {
                $Result = Get-FplTeam 3>&1
                $Result.Message | Should -Contain 'No existing connection found'
            }
            It "connects to the FPL API and returns the user's team" {
                $Result = Get-FplTeam -WarningAction SilentlyContinue
                Assert-MockCalled Connect-Fpl -Scope 'It'
                $Result | Should -Be '12345'
            }
        }
        Context 'No TeamId whilst logged in' {
            BeforeAll {
                Mock Get-FplUserTeam {}
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                    CsrfToken  = 'csrftoken'
                }
                $Results = Get-FplTeam
            }
            It 'calls Get-FplUserTeam when no parameter is given' {
                Assert-MockCalled Get-FplUserTeam
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplTeam -TeamId 123456 3>&1 | Should -Be 'The game is being updated. Please try again shortly.'
            }
        }
    }
}
