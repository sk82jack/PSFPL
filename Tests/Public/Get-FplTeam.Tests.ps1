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
                $Results = Get-FplTeam -TeamId 123456
            }
            It 'passes the TeamId onto Invoke-RestMethod' {
                Assert-MockCalled Invoke-RestMethod
            }
        }
        Context 'No TeamID whilst not logged in' {
            BeforeAll {
                $Result = Get-FplTeam 3>&1
            }
            It 'returns a warning' {
                $Result.Message | Should -Be 'Please either login with the Connect-FPL function or specify a team ID'
            }
        }
        Context 'No TeamId whilst logged in' {
            BeforeAll {
                Mock Get-FplUserTeam {}
                $Script:FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                $Results = Get-FplTeam
            }
            It 'calls Get-FplUserTeam when no parameter is given' {
                Assert-MockCalled Get-FplUserTeam
            }
        }
    }
}
