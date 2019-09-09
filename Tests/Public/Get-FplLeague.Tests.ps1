Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplLeague' {
        BeforeAll {
            Mock Get-Credential {
                $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                [Management.Automation.PSCredential]::new('UserName', $Password)
            }
            Mock Connect-Fpl {
                $Script:FplSessionData = @{
                    TeamID = 12345
                }
            }
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    leagues = $true
                }
            }
            Mock ConvertTo-FplObject {}
        }
        AfterEach {
            Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction 'SilentlyContinue'
        }
        Context 'No TeamId specified' {
            It 'runs Connect-Fpl if no connection exists' {
                $Result = Get-FplLeague 3>&1
                Assert-MockCalled Connect-Fpl -Exactly 1 -Scope 'It'
            }
            It "doesn't run Connect-Fpl if a connection exists" {
                $Script:FplSessionData = @{
                    FplSession = $true
                }
                Get-FplLeague
                Assert-MockCalled Connect-Fpl -Exactly 0 -Scope 'It'
            }
            It 'gets the users team if no TeamId parameter is given' {
                $Script:FplSessionData = @{
                    FplSession = $true
                    TeamID     = 12345
                }
                Get-FplLeague
                Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/12345/'
                }
            }
        }
        Context 'TeamId specified' {
            It 'passes the TeamId onto Invoke-RestMethod correctly' {
                Get-FplLeague -TeamId 654321
                Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/654321/'
                }
            }
            It 'accepts pipeline input' {
                654321 | Get-FplLeague
                Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/654321/'
                }
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplLeague -TeamId 654321 3>&1 | Should -Be 'The game is being updated. Please try again shortly.'
            }
        }
    }
}
