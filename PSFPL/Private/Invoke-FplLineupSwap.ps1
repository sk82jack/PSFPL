function Invoke-FplLineupSwap {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSTypeName('FplLineup')]
        [PSObject[]]
        $Lineup,

        [Parameter(Mandatory)]
        [PSTypeName('FplLineup')]
        [PSObject[]]
        $PlayersIn,

        [Parameter(Mandatory)]
        [PSTypeName('FplLineup')]
        [PSObject[]]
        $PlayersOut
    )

    $Def = '
        namespace FPL
        {
            namespace Player
            {
                public enum Position
                {
                    Goalkeeper = 0,
                    Defender = 100,
                    Midfielder = 200,
                    Forward = 300
                }
            }
        }
    '
    Add-Type -TypeDefinition $Def

    foreach ($Index in 0..($PlayersIn.Count - 1)) {
        $InPlayer = $PlayersIn[$Index].psobject.copy()
        $OutPlayer = $PlayersOut[$Index].psobject.copy()

        foreach ($Property in 'PlayerId', 'Position', 'Name') {
            $Lineup.Where{$_.PositionNumber -eq $OutPlayer.PositionNumber}[0].$Property = $InPlayer.$Property
            $Lineup.Where{$_.PositionNumber -eq $InPlayer.PositionNumber}[0].$Property = $OutPlayer.$Property
        }

        $IsSamePosition = $InPlayer.Position -eq $OutPlayer.Position
        $AreBothSubstitutes = $InPlayer.IsSub -and $OutPlayer.IsSub

        if ((-not $IsSamePosition) -and (-not $AreBothSubstitutes)) {
            $Starters, $Substitutes = $Lineup.Where( {-not $_.IsSub}, 'Split')
            $SortOrder = @(
                {[enum]::GetNames([FPL.Player.Position]).IndexOf($_)}
                {[Fpl.Player.Position]$_.Position + [int]$_.PositionNumber}
            )
            $NewStarters = $Starters | Sort-Object $SortOrder
            $Lineup = $NewStarters + $Substitutes
            $Counter = 1
            $Lineup.Foreach{
                $_.PositionNumber = $Counter
                $Counter++
            }
        }
    }

    $Lineup
}
