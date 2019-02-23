Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplUserTeam' {
        BeforeAll {
            $Script:FplSessionData = @{
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            }
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    entry = 123456
                }
            }
            Mock ConvertTo-FplObject {}
            $Result = Get-FplUserTeam
        }
        It 'calls the transfers API URL' {
            Assert-MockCalled Invoke-RestMethod -ParameterFilter {$Uri -eq 'https://fantasy.premierleague.com/drf/transfers'}
        }
        It 'converts the API response to an FplTeam object' {
            Assert-MockCalled ConvertTo-FplObject -ParameterFilter {$Type -eq 'FplTeam'}
        }
        AfterAll {
            Remove-Variable -Name 'FplSessionData' -Scope 'Script'
        }
    }
}
