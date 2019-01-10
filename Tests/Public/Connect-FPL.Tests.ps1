Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Connect-FPL' {
        BeforeAll {
            $Password = ConvertTo-SecureString "password" -AsPlainText -Force
            $GoodCreds = [Management.Automation.PSCredential]::new("GoodUserName", $Password)
            $BadCreds = [Management.Automation.PSCredential]::new("BadUserName", $Password)

            Mock Invoke-WebRequest -ParameterFilter {$SessionVariable -eq 'FplSession'} {
                [PSCustomObject]@{
                    InputFields = @(
                        [pscustomobject]@{
                            name  = 'csrfmiddlewaretoken'
                            value = 'csrfmiddlewaretoken'
                        }
                    )
                }
                $Script:FplSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            }

            Mock Invoke-WebRequest -ParameterFilter {$Body -and $Body['login'] -eq 'BadUserName'} {
                [PSCustomObject]@{
                    Headers = @{
                        'Set-Cookie' = $false
                    }
                }
            }

            Mock Invoke-WebRequest -ParameterFilter {$Body -and $Body['login'] -eq 'GoodUserName'} {
                [PSCustomObject]@{
                    Headers = @{
                        'Set-Cookie' = @(
                            'csrftoken=gLQjahvAQrHPKMAaCru1MZiSSkwRbbNN; expires=Wed, 25-Dec-2019 14:21:20 GMT; Max-Age=31449600; Path=/'
                            'sessionid=".eJyrVkpPzE2NT85PSVWyUirISSvIUdJRik8sLcmILy1OLYpPSkzOTs1LAUsmVqYW6UEFivUCwHwnqDyKpkyg-mhDHXNTM0szI_PYWgBVsyN-:1gcA3k:qSFMS32dMMJ6mC29t3zXnrCTzgA"; httponly; Path=/'
                            'affiliate=; expires=Thu, 01-Jan-1970 00:00:00 GMT; Max-Age=0; Path=/'
                            'one-click-join=; expires=Thu, 01-Jan-1970 00:00:00 GMT; Max-Age=0; Path=/'
                        )
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
                Remove-Variable -Name 'FplSession' -Scope 'Script' -ErrorAction 'SilentlyContinue'
                {Connect-FPL -Credential $BadCreds} | Should -Throw
            }
            It "doesn't throw a terminating error if good credentials are given" {
                Remove-Variable -Name 'FplSession' -Scope 'Script' -ErrorAction 'SilentlyContinue'
                {Connect-FPL -Credential $GoodCreds} | Should -Not -Throw
            }
            It "doesn't connect if an existing connection exists" {
                Remove-Variable -Name 'FplSession' -Scope 'Script' -ErrorAction 'SilentlyContinue'
                Connect-FPL -Credential $GoodCreds
                $Response = Connect-FPL -Credential $GoodCreds 3>&1
                $Response.Message | Should -Be 'A connection already exists. Use the Force parameter to connect.'
            }
            It "connects if an existing connection exists but we use the force parameter" {
                Remove-Variable -Name 'FplSession' -Scope 'Script' -ErrorAction 'SilentlyContinue'
                Connect-FPL -Credential $GoodCreds
                $Response = Connect-FPL -Credential $GoodCreds -Force 3>&1
                $Response.Message | Should -BeNullOrEmpty
            }
        }
        Context 'Output' {
            It 'adds the FPL session is available within the module scope' {
                Remove-Variable -Name 'FplSession' -Scope 'Script' -ErrorAction 'SilentlyContinue'
                Connect-FPL -Credential $GoodCreds
                $FplSession | Should -Not -BeNullOrEmpty
                $FplSession | Should -BeOfType 'Microsoft.PowerShell.Commands.WebRequestSession'
            }
        }
    }
}
