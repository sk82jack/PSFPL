Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplLeagueTable' {
        BeforeAll {
            Mock Write-Warning {}
            Mock Get-Credential {
                $Password = ConvertTo-SecureString 'password' -AsPlainText -Force
                [Management.Automation.PSCredential]::new('UserName', $Password)
            }
            Mock Connect-Fpl {
                $Script:FplSessionData = @{
                    FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                }
            }
            Mock ConvertTo-FplObject {$true}
        }
        AfterAll {
            Remove-Variable -Name 'FplSessionData' -Scope 'Script'
        }
        Context 'Normal circumstances' {
            BeforeAll {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page_standings=1$'} {
                    [PSCustomObject]@{
                        standings = [PSCustomObject]@{
                            has_next = $true
                        }
                    }
                }
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page_standings=2$'} {
                    [PSCustomObject]@{
                        standings = [PSCustomObject]@{
                            has_next = $false
                        }
                    }
                }
            }
            It 'prompts for authentication if not already logged in' {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Connect-Fpl -Scope 'It'
            }
            It 'loops through all the league standing pages' {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Invoke-RestMethod -Exactly 2 -Scope It
            }
            It 'processes parameter input' {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/leagues-classic/12345/standings/?page_new_entries=1&page_standings=1'
                }
            }
            It 'processes pipeline input for an FplLeague object' {
                $League = [PSCustomObject]@{
                    PSTypeName = 'FplLeague'
                    LeagueId   = 56789
                    Scoring    = 'H2H'
                }

                $League | Get-FplLeagueTable
                Assert-MockCalled Invoke-RestMethod -ParameterFilter {
                    $Uri -eq 'https://fantasy.premierleague.com/api/leagues-h2h/56789/standings/?page_new_entries=1&page_standings=1'
                }
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod -ParameterFilter {$Uri -match 'page_standings=1$'} {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Write-Warning -Scope 'It' -ParameterFilter {
                    $Message -eq 'The game is being updated. Please try again shortly.'
                }
            }
        }
        Context "When the league doesn't exist" {
            BeforeAll {
                Mock Invoke-RestMethod { throw }
            }
            It "shows a warning when a league doesn't exist" {
                Get-FplLeagueTable -LeagueId 12345 -Type 'Classic'
                Assert-MockCalled Invoke-RestMethod -Scope 'It'
                Assert-MockCalled Write-Warning -Scope 'It' -ParameterFilter {
                    $Message -eq 'A Classic league with ID 12345 does not exist'
                }
            }
        }
    }
}
