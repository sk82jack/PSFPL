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
            Mock Get-FplGameweek {
                [PSCustomObject]@{
                    Gameweek = 13
                }
            }
            Mock Write-Warning {}
        }
        Context 'TeamId and Gameweek supplied' {
            It 'passes the TeamId onto Invoke-RestMethod' {
                Get-FplTeamPlayer -TeamId 123456 -Gameweek 13
                Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/123456/event/13/picks/'
                }
            }
        }
        Context 'No TeamId whilst not logged in' {
            BeforeAll {
                Mock Get-Credential {
                    $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                    [Management.Automation.PSCredential]::new('UserName', $Password)
                }
                Mock Connect-Fpl {
                    $Script:FplSessionData = @{
                        FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                        TeamID     = 12345
                        CurrentGW  = 13
                    }
                }
            }
            AfterEach {
                Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction 'SilentlyContinue'
            }
            It 'returns a warning' {
                Get-FplTeamPlayer -Gameweek 12
                Assert-MockCalled Write-Warning -Scope 'It' -ParameterFilter {
                    $Message -eq 'No existing connection found'
                }
            }
            It "connects to the FPL API" {
                Get-FplTeamPlayer -Gameweek 12
                Assert-MockCalled Connect-Fpl -Scope 'It'
            }
        }
        Context 'No TeamId whilst logged in' {
            BeforeAll {
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                    TeamID     = 12345
                    CurrentGW  = 13
                }
            }
            AfterAll {
                Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction 'SilentlyContinue'
            }
            It 'gets logged in user team and current gameweek from cache' {
                Get-FplTeamPlayer -Gameweek 12
                Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/12345/event/12/picks/'
                }
            }
        }
        Context 'No Gameweek parameter supplied' {
            AfterEach {
                Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction 'SilentlyContinue'
            }
            It 'calls Get-FplGameweek when no parameter is given and the user has not authenticated' {
                Get-FplTeamPlayer -TeamId 123456
                Assert-MockCalled Get-FplGameweek -Scope 'It'
            }
            It 'gets the current gameweek from the FplSessionData variable when authenticated' {
                $Script:FplSessionData = @{
                    CurrentGW = 27
                }
                Get-FplTeamPlayer -TeamId 123456
                Assert-MockCalled Invoke-RestMethod -Scope 'It' -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/entry/123456/event/27/picks/'
                }
            }
        }
        Context 'Error handling' {
            It 'throws an error if you specify a future gameweek' {
                {Get-FplTeamPlayer -TeamId 123456 -Gameweek 38} | Should -Throw -ExpectedMessage 'Cannot view team because the gameweek has not started yet'
            }
            It 'shows a warning when the game is updating' {
                Mock Invoke-RestMethod {'The game is being updated.'}
                Get-FplTeamPlayer -TeamId 123456 -Gameweek 12
                Assert-MockCalled Write-Warning -Scope 'It' -ParameterFilter {
                    $Message -eq 'The game is being updated. Please try again shortly.'
                }
            }
            It 'throws an error if the manager did not have a team in the specified gameweek' {
                Mock Invoke-RestMethod {
                    $Exception = [Exception]::new('Not found')
                    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        $Exception,
                        "NotFound",
                        'NotSpecified',
                        $null
                    )
                    $ErrorRecord.ErrorDetails = '{"detail":"Not found."}'
                    Write-Error -ErrorRecord $ErrorRecord -ErrorAction 'Stop'
                }
                {Get-FplTeamPlayer -TeamId 123456 -Gameweek 1} | Should -Throw -ExpectedMessage 'Team did not exist in gameweek 1'
            }
            It 're-throws unknown errors from the API' {
                Mock Invoke-RestMethod {
                    $Exception = [Exception]::new('Unknown Error')
                    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        $Exception,
                        "UnknownError",
                        'NotSpecified',
                        $null
                    )
                    $ErrorRecord.ErrorDetails = 'Unknown error'
                    Write-Error -ErrorRecord $ErrorRecord -ErrorAction 'Stop'
                }
                {Get-FplTeamPlayer -TeamId 123456 -Gameweek 1} | Should -Throw -ExpectedMessage 'Unknown Error'
            }
        }
    }
}
