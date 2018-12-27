Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplTeam' {
        BeforeAll {
            Mock ConvertTo-FplObject {$true}
        }
        Context 'TeamId passed' {
            BeforeAll {
                Mock Invoke-RestMethod {
                    [PSCustomObject]@{
                        entry = $true
                    }
                }
                $Results = Get-FplTeam -TeamId 101298
            }
            It 'passes the TeamId onto Invoke-RestMethod' {
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -match '101298$'}
            }
        }
        Context 'No TeamID whilst not logged in' {
            BeforeAll {
                Mock Invoke-RestMethod {$true}
                $Results = Get-FplTeam -WarningAction SilentlyContinue
            }
            It 'returns no output' {
                $Result | Should -BeNullOrEmpty
                Assert-MockCalled Invoke-RestMethod -Exactly 0
            }
        }
        Context 'No TeamId whilst logged in' {
            BeforeAll {
                Mock Invoke-RestMethod {
                    [PSCustomObject]@{
                        entry = $true
                    }
                }
                $Script:FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                $Results = Get-FplTeam
            }
            It 'uses the transfers URL when no parameter is given' {
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -match 'transfers$'}
            }
        }
    }
}
