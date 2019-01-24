Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplTeamPlayer' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    picks = $true
                }
            }
            Mock ConvertTo-FplObject {}
        }
        Context 'TeamId and Gameweek supplied' {
            It 'passes the TeamId onto Invoke-RestMethod' {
                $Results = Get-FplTeamPlayer -TeamId 123456 -Gameweek 13
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/drf/entry/123456/event/13/picks'} -Scope 'It'
            }
        }
        Context 'No TeamID whilst not logged in' {
            BeforeAll {
                Mock Get-Credential {
                    $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                    [Management.Automation.PSCredential]::new('UserName', $Password)
                }
                Mock Connect-Fpl {}
                Mock Get-FplUserTeam {'12345'}
            }
            It 'returns a warning' {
                $Result = Get-FplTeamPlayer -Gameweek 14 3>&1
                $Result.Message | Should -Contain 'No existing connection found'
            }
            It "connects to the FPL API" {
                $Result = Get-FplTeamPlayer -Gameweek 14 -WarningAction SilentlyContinue
                Assert-MockCalled Connect-Fpl -Scope 'It'
            }
        }
        Context 'No TeamId whilst logged in' {
            BeforeAll {
                Mock Get-FplUserTeam {}
                $Script:FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            }
            AfterAll {
                Remove-Variable -Name 'FplSession' -Scope 'Script'
            }
            It 'calls Get-FplUserTeam when no parameter is given' {
                $Results = Get-FplTeamPlayer -Gameweek 13
                Assert-MockCalled Get-FplUserTeam -Scope 'It'
            }
        }
        Context 'No Gameweek parameter supplied' {
            BeforeAll {
                Mock Get-FplGameweek {
                    [PSCustomObject]@{
                        Gameweek = 13
                    }
                }
            }
            It 'calls Get-FplGameweek when no parameter is given' {
                $Result = Get-FplTeamPlayer -TeamId 123456
                Assert-MockCalled Get-FplGameweek -Scope 'It'
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplTeamPlayer -TeamId 123456 -Gameweek 12 3>&1 | Should -Be 'The game is being updated. Please try again shortly.'
            }
        }
    }
}
