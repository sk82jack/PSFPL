Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'PlayerTransformAttribute' {
        BeforeAll {
            function Test-Function {
                [CmdletBinding()]
                param (
                    [Parameter()]
                    [PlayerTransformAttribute()]
                    $Player
                )
                $Player
            }
        }
        It 'converts a string to a PSCustomObject' {
            $Output = Test-Function -Player 'Salah'
            $Output.Name | Should -Be '^Salah$'
        }
        It 'converts an integer to a PSCustomObject' {
            $Output = Test-Function -Player 45
            $Output.PlayerId | Should -Be 45
        }
        It 'converts a hashtable to a PSCustomObject' {
            $Output = Test-Function -Player @{Name = 'Salah'; Club = 'Liverpool'}
            $Output.Name | Should -Be '^Salah$'
            $Output.Club | Should -Be 'Liverpool'
        }
        It 'passes an FplLineup object through' {
            $InputObject = [PSCustomObject]@{
                PSTypeName = 'FplLineup'
                Name       = 'Salah'
            }
            $Output = Test-Function -Player $InputObject
            $Output.Name | Should -Be 'Salah'
            $Output.PSTypeNames | Should -Contain 'FplLineup'
        }
        It 'passes an FplPlayer object through' {
            $InputObject = [PSCustomObject]@{
                PSTypeName = 'FplPlayer'
                Name       = 'Salah'
            }
            $Output = Test-Function -Player $InputObject
            $Output.Name | Should -Be 'Salah'
            $Output.PSTypeNames | Should -Contain 'FplPlayer'
        }
        It 'throws for an unknown type' {
            $ExpectedMessage = 'You must provide a string, integer, hashtable or FPL player object.'
            {Test-Function -Player 1.5} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'throws if a name or player ID is not specified' {
            $ExpectedMessage = 'You must specify a Name or PlayerId.'
            {Test-Function -Player @{Club = 'Liverpool'; FirstName = 'Mohamed'}} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
        It 'throws if there are unknown hashtable keys' {
            $ExpectedMessage = 'Invalid properties found.'
            {Test-Function -Player @{Name = 'Salah'; Club = 'Liverpool'; FirstName = 'Mohamed'}} | Should -Throw -ExpectedMessage $ExpectedMessage
        }
    }
}
