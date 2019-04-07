Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Write-FplError' {
        BeforeAll {
            $LineupError = [PSCustomObject]@{
                details = [PSCustomObject]@{
                    non_field_errors = @(
                        'TXFER_ET_BAD_COUNT::You need to select between 1 and 1 Goalkeepers. 2 were selected.'
                    )
                    errors           = @()
                }
            }
            $NegativeBankError = [PSCustomObject]@{
                non_form_errors = @(
                    'TXFER_NEGATIVE_BANK::Negative bank balance -15 is not allowed.'
                )
                errors          = @()
            }
            $NoTransfersError = [PSCustomObject]@{
                non_form_errors = @(
                    'TXFER_NO_TRANSFERS::No transfers are being made.'
                )
            }
            $FreehitError = [PSCustomObject]@{
                errors = [PSCustomObject]@{
                    freehit = @(
                        'TXFER_FH_NOT_AVAILABLE::Free hit is not available to play.'
                    )
                }
            }
            $WildcardError = [PSCustomObject]@{
                errors = [PSCustomObject]@{
                    wildcard = @(
                        'TXFER_WC_NOT_AVAILABLE::The wildcard is not available to play.'
                    )
                }
            }
        }
        It 'parses and replaces the negative bank balance error' {
            $ExpectedMessage = 'Negative bank balance -{0}1.5m is not allowed.' -f [char]163
            {Write-FplError -FplError $NegativeBankError} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'parses a generic non form error' {
            $ExpectedMessage = 'No transfers are being made'
            {Write-FplError -FplError $NoTransfersError} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'parses a generic non field error' {
            $ExpectedMessage = 'You need to select between 1 and 1 Goalkeepers. 2 were selected.'
            {Write-FplError -FplError $LineupError} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'parses a freehit error' {
            $ExpectedMessage = 'Free hit is not available to play.'
            {Write-FplError -FplError $FreehitError} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'parses a wildcard error' {
            $ExpectedMessage = 'The wildcard is not available to play.'
            {Write-FplError -FplError $WildcardError} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
    }
}
