Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Connect-FPL' {
        BeforeAll {
            $Password = ConvertTo-SecureString "password" -AsPlainText -Force
            $Creds = [Management.Automation.PSCredential]::new("UserName", $Password)
        }
        Context 'Input' {
            It 'Credential parameter is mandatory' {
                (Get-Command Connect-FPL).Parameters['Credential'].Attributes.Mandatory | should be $true
            }
        }
        Context 'Execution' {
            BeforeAll {
                Mock Invoke-WebRequest {
                    [PSCustomObject]@{
                        Headers = [PSCustomObject]@{
                            'Set-Cookie' = $false
                        }
                    }
                }
            }
            It 'If incorrect credentials are given, throws a terminating error' {
                {Connect-FPL -Credential $Creds} | Should -Throw
            }
        }
    }
}
