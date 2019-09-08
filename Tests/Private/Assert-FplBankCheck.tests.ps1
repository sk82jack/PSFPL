Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Assert-FplBankCheck' {
        It 'throws an error if the proposed transfer leaves a negative bank balanece' {
            $Params = @{
                Bank       = 0
                PlayersIn  = [PSCustomObject]@{
                    Price = 7
                }
                PlayersOut = [PSCustomObject]@{
                    SellingPrice = 6.5
                }
            }
            {Assert-FplBankCheck @Params} | Should -Throw
        }
        It 'does not throw an error if the proposed transfer does not leave a negative bank balanece' {
            $Params = @{
                Bank       = 0
                PlayersIn  = [PSCustomObject]@{
                    Price = 6.5
                }
                PlayersOut = [PSCustomObject]@{
                    SellingPrice = 7
                }
            }
            {Assert-FplBankCheck @Params} | Should -Not -Throw
        }
    }
}
