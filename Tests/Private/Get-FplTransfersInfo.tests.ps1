Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplTransfersInfo' {
        BeforeAll {
            $Script:FplSessionData = @{
                TeamID     = 12345
                FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            }
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    transfers = @{
                        cost   = 4
                        status = 'cost'
                        limit  = 0
                        made   = 2
                        bank   = 1
                        value  = 1004
                    }
                }
            }
        }
        It 'gets the transfer information using the logged in team ID' {
            Get-FplTransfersInfo
            Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                $Uri -eq 'https://fantasy.premierleague.com/api/my-team/12345/'
            }
        }
    }
}
