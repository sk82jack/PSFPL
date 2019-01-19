Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-FplPlayer' {
        BeforeAll {
            Mock Invoke-RestMethod {$true}
            Mock ConvertTo-FplObject {
                @(
                    [pscustomobject]@{
                        WebName     = 'Ederson'
                        Position    = 'Goalkeeper'
                        Club        = 'Man City'
                        Price       = 5.8
                        InDreamTeam = $true
                        TotalPoints = 62
                    },
                    [pscustomobject]@{
                        WebName     = 'Alonso'
                        Position    = 'Defender'
                        Club        = 'Chelsea'
                        Price       = 7.1
                        InDreamTeam = $true
                        TotalPoints = 86
                    },
                    [pscustomobject]@{
                        WebName     = 'Richarlison'
                        Position    = 'Midfielder'
                        Club        = 'Everton'
                        Price       = 7.0
                        InDreamTeam = $false
                        TotalPoints = 59
                    },
                    [pscustomobject]@{
                        WebName     = 'Arnautovic'
                        Position    = 'Forward'
                        Club        = 'West Ham'
                        Price       = 7.1
                        InDreamTeam = $false
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
                $Result.WebName | Should -Be 'Ederson'

                $Result = Get-FplPlayer -Name 'ar'
                $Result.WebName | Should -Contain 'Arnautovic'
                $Result.WebName | Should -Contain 'Richarlison'
                $Result.WebName | Should -Not -Contain 'Ederson'
            }
            It 'Filters correctly on the Position parameter' {
                $Result = Get-FplPlayer -Position 'Defender'
                $Result.WebName | Should -Be 'Alonso'
            }
            It 'Filters correctly on the Club parameter' {
                $Result = Get-FplPlayer -Club 'Chelsea'
                $Result.WebName | Should -Be 'Alonso'
            }
            It 'Filters correctly on the MaxPrice parameter' {
                $Result = Get-FplPlayer -MaxPrice 7
                $Result.count | Should -Be 2
                $Result.WebName | Should -Contain 'Ederson'
                $Result.WebName | Should -Not -Contain 'Alonso'
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
                $Result.WebName | Should -Contain 'Alonso'
                $Result.WebName | Should -Not -Contain 'Arnautovic'
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
