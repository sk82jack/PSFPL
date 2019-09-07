Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Connect-FPL' {
        BeforeAll {
            $Password = ConvertTo-SecureString "password" -AsPlainText -Force
            $GoodCreds = [Management.Automation.PSCredential]::new("GoodUserName", $Password)
            $BadCreds = [Management.Automation.PSCredential]::new("BadUserName", $Password)

            Mock Write-Warning {}

            Mock Invoke-WebRequest -ParameterFilter {$SessionVariable -eq 'FplSession'} {
                $Password = $Body['password'] | ConvertTo-SecureString -AsPlainText -Force
                $Credential = [pscredential]::new($Body['login'], $Password)
                $Script:FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]@{
                    Credentials = $Credential
                }
            }

            Mock Invoke-RestMethod -ParameterFilter {$WebSession -and $WebSession.Credentials.UserName -eq 'BadUserName'} {}

            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    player = [PSCustomObject]@{
                        entry = 12345
                    }
                }
            }
        }
        Context 'Input' {
            It 'Credential parameter is mandatory' {
                (Get-Command Connect-FPL).Parameters['Credential'].Attributes.Mandatory | Should -BeTrue
            }
        }
        Context 'Execution' {
            It 'throws a terminating error if bad credentials are given' {
                {Connect-FPL -Credential $BadCreds} | Should -Throw
            }
            It "doesn't throw a terminating error if good credentials are given" {
                {Connect-FPL -Credential $GoodCreds} | Should -Not -Throw
            }
            It "doesn't connect if an existing connection exists" {
                Connect-FPL -Credential $GoodCreds
                Connect-FPL -Credential $GoodCreds
                $ExpectedMessage = 'A connection already exists. Use the Force parameter to connect.'
                Assert-MockCalled Write-Warning -ParameterFilter {$Message -eq $ExpectedMessage} -Scope 'It'
            }
            It "connects if an existing connection exists but we use the force parameter" {
                Connect-FPL -Credential $GoodCreds
                Connect-FPL -Credential $GoodCreds -Force
                $ExpectedMessage = 'A connection already exists. Use the Force parameter to connect.'
                Assert-MockCalled Write-Warning -ParameterFilter {$Message -eq $ExpectedMessage} -Scope 'It' -Exactly 0
            }
        }
        Context 'Output' {
            It 'adds the FPL session data to the module scope' {
                Connect-FPL -Credential $GoodCreds
                $FplSessionData | Should -Not -BeNullOrEmpty
                $FplSessionData['FplSession'] | Should -BeOfType 'Microsoft.PowerShell.Commands.WebRequestSession'
                $FplSessionData['TeamID'] | Should -Be 12345
            }
        }
        AfterEach {
            Remove-Variable -Name 'FplSessionData' -Scope 'Script' -ErrorAction SilentlyContinue
        }
    }
}
