Import-Module $env:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplSpentPoints' {
        It 'calculates hits with transfers already made' {
            $TransferInfo = @{
                cost   = 4
                status = 'cost'
                limit  = 2
                made   = 2
                bank   = 1
                value  = 1004
            }
            $Results = Get-FplSpentPoints -TransfersCount 2 -TransfersInfo $TransferInfo
            $Results | Should -Be 8
        }
        It 'calculates hits with no transfers already made' {
            $TransferInfo = @{
                cost   = 4
                status = 'cost'
                limit  = 2
                made   = 0
                bank   = 1
                value  = 1004
            }
            $Results = Get-FplSpentPoints -TransfersCount 3 -TransfersInfo $TransferInfo
            $Results | Should -Be 4
        }
        It 'calculates no hits with transfers already made' {
            $TransferInfo = @{
                cost   = 4
                status = 'cost'
                limit  = 2
                made   = 1
                bank   = 1
                value  = 1004
            }
            $Results = Get-FplSpentPoints -TransfersCount 1 -TransfersInfo $TransferInfo
            $Results | Should -Be 0
        }
        It 'calculates no hits with no transfers already made' {
            $TransferInfo = @{
                cost   = 4
                status = 'cost'
                limit  = 2
                made   = 0
                bank   = 1
                value  = 1004
            }
            $Results = Get-FplSpentPoints -TransfersCount 1 -TransfersInfo $TransferInfo
            $Results | Should -Be 0
        }
        It 'does not count hits before first gameweek' {
            $TransferInfo = @{
                cost   = 4
                status = 'unlimited'
                limit  = $null
                made   = 0
                bank   = 3
                value  = 997
            }
            $Results = Get-FplSpentPoints -TransfersCount 2 -TransfersInfo $TransferInfo
            $Results | Should -Be 0
        }
    }
}
