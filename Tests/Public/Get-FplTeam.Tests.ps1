Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplTeam' {
        BeforeAll {
            Mock Invoke-RestMethod {$true}
            Mock ConvertTo-FplObject {}
            Mock Write-Warning {}
        }
        Context 'TeamId passed' {
            BeforeAll {
                Mock Invoke-RestMethod {
                    [PSCustomObject]@{
                        entry = $true
                    }
                }
            }
            It 'passes the TeamId onto Invoke-RestMethod' {
                Get-FplTeam -TeamId 123456
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/api/entry/123456/'} -Scope 'It'
            }
            It 'accepts pipeline input' {
                123456 | Get-FplTeam
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/api/entry/123456/'} -Scope 'It'
            }
        }
        Context 'Not passing explicit team ID' {
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
            }
            It 'prompts for authentication if not already connected' {
                Get-FplTeam
                Assert-MockCalled Connect-Fpl -Scope 'It'
            }
            It 'uses cached team ID if logged in' {
                Get-FplTeam
                Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/12345/'
                }
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplTeam -TeamId 123456
                Assert-MockCalled Write-Warning -Scope 'It' -ParameterFilter {
                    $Message -eq 'The game is being updated. Please try again shortly.'
                }
            }
        }
    }
}
