Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplPlayer' {
        BeforeAll {
            Mock Invoke-RestMethod {$true}
            Mock ConvertTo-FplObject {
                @(
                    [pscustomobject]@{
                        Name     = 'Ederson'
                        Position    = 'Goalkeeper'
                        Club        = 'Man City'
                        Price       = 5.8
                        InDreamClub = $true
                        TotalPoints = 62
                    },
                    [pscustomobject]@{
                        Name     = 'Alonso'
                        Position    = 'Defender'
                        Club        = 'Chelsea'
                        Price       = 7.1
                        InDreamClub = $true
                        TotalPoints = 86
                    },
                    [pscustomobject]@{
                        Name     = 'Richarlison'
                        Position    = 'Midfielder'
                        Club        = 'Everton'
                        Price       = 7.0
                        InDreamClub = $false
                        TotalPoints = 59
                    },
                    [pscustomobject]@{
                        Name     = 'Arnautovic'
                        Position    = 'Forward'
                        Club        = 'West Ham'
                        Price       = 7.1
                        InDreamClub = $false
                        TotalPoints = 52
                    }
                )
            }
        }
        Context 'Filter' {
            It 'Defining no filters retrieves all players' {
                $Results = Get-FplPlayer
                $Results.count | Should -Be 4
            }
            It 'Filters correctly on the Name parameter' {
                $Result = Get-FplPlayer -Name 'Ederson'
                $Result.Name | Should -Be 'Ederson'

                $Result = Get-FplPlayer -Name 'ar'
                $Result.Name | Should -Contain 'Arnautovic'
                $Result.Name | Should -Contain 'Richarlison'
                $Result.Name | Should -Not -Contain 'Ederson'
            }
            It 'accepts pipeline input on the Name parameter' {
                $Result = 'Ederson' | Get-FplPlayer
                $Result.Name | Should -Be 'Ederson'
            }
            It 'Filters correctly on the Position parameter' {
                $Result = Get-FplPlayer -Position 'Defender'
                $Result.Name | Should -Be 'Alonso'
            }
            It 'Filters correctly on the Club parameter' {
                $Result = Get-FplPlayer -Club 'Chelsea'
                $Result.Name | Should -Be 'Alonso'
            }
            It 'Filters correctly on the MaxPrice parameter' {
                $Result = Get-FplPlayer -MaxPrice 7
                $Result.count | Should -Be 2
                $Result.Name | Should -Contain 'Ederson'
                $Result.Name | Should -Not -Contain 'Alonso'
            }
            It 'Sorts by TotalPoints' {
                $Result = Get-FplPlayer
                $Result[0].TotalPoints | Should -Be 86
                $Result[1].TotalPoints | Should -Be 62
                $Result[2].TotalPoints | Should -Be 59
                $Result[3].TotalPoints | Should -Be 52
            }
            It 'Sorts by price then TotalPoints when specifying the MaxPrice parameter' {
                $Result = Get-FplPlayer -MaxPrice 7.1
                $Result[0].TotalPoints | Should -Be 86
                $Result[1].TotalPoints | Should -Be 52
                $Result[2].Price | Should -Be 7
                $Result[3].Price | Should -Be 5.8
            }
        }
        Context 'Dream Team' {
            BeforeAll {
                $Result = Get-FplPlayer -DreamTeam
            }
            It 'Only lists players in the dream team' {
                $Result.Name | Should -Contain 'Alonso'
                $Result.Name | Should -Not -Contain 'Arnautovic'
            }

            It 'Outputs the dream team in the correct order' {
                $Result.Position[0] | Should -Be 'Goalkeeper'
                $Result.Position[1] | Should -Be 'Defender'
            }
        }
        Context 'When the game is updating' {
            BeforeAll {
                Mock Invoke-RestMethod {'The game is being updated.'}
            }
            It 'shows a warning when the game is updating' {
                Get-FplPlayer -DreamTeam 3>&1 | Should -Be 'The game is being updated. Please try again shortly.'
            }
        }
    }
}
