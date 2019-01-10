Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplLeague' {
        BeforeAll {
            Mock Get-Credential {
                $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                [Management.Automation.PSCredential]::new('UserName', $Password)
            }
            Mock Connect-Fpl {}
            Mock Get-FplUserTeam {
                [PSCustomObject]@{
                    TeamId = 12345
                }
            }
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    leagues = $true
                }
            }
            Mock ConvertTo-FplObject {}
        }
        Context 'No TeamId specified' {
            It 'runs Connect-Fpl if no connection exists' {
                Remove-Variable -Name 'FplSession' -Scope 'Script' -ErrorAction SilentlyContinue
                $Result = Get-FplLeague 3>&1
                Assert-MockCalled Connect-Fpl -Exactly 1 -Scope 'It'
            }
            It "doesn't run Connect-Fpl if a connection exists" {
                $Script:FplSession = $true
                Get-FplLeague
                Assert-MockCalled Connect-Fpl -Exactly 0 -Scope 'It'
            }
            It 'gets the users team if no TeamId parameter is given' {
                $Script:FplSession = $true
                Get-FplLeague
                Assert-MockCalled Get-FplUserTeam -Exactly 1 -Scope 'It'
            }
        }
        Context 'TeamId specified' {
            It 'passes the TeamId onto Invoke-RestMethod correctly' {
                Get-FplLeague -TeamId 654321
                Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/drf/entry/654321'
                }
            }
        }
    }
}
