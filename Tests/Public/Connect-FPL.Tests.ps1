Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Connect-FPL' {
        BeforeAll {
            $Password = ConvertTo-SecureString "password" -AsPlainText -Force
            $Creds = [Management.Automation.PSCredential]::new("UserName", $Password)

            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    InputFields = @(
                        [pscustomobject]@{
                            name  = 'csrfmiddlewaretoken'
                            value = 'csrfmiddlewaretoken'
                        }
                    )
                    Headers     = [PSCustomObject]@{
                        'Set-Cookie' = $false
                    }
                }
            }
        }
        Context 'Input' {
            It 'Credential parameter is mandatory' {
                (Get-Command Connect-FPL).Parameters['Credential'].Attributes.Mandatory | should be $true
            }
        }
        Context 'Execution' {
            It 'If incorrect credentials are given, throws a terminating error' {
                {Connect-FPL -Credential $Creds} | Should -Throw
            }
        }
    }
}
