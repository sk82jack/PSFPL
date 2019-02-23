function Invoke-FplLineupSwap {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Lineup,

        [Parameter(Mandatory)]
        [string[]]
        $PlayersIn,

        [Parameter(Mandatory)]
        [string[]]
        $PlayersOut
    )

    $Def = '
        namespace FPL
        {
            namespace Player
            {
                public enum Position
                {
                    GoalKeeper = 0,
                    Defender = 100,
                    Midfielder = 200,
                    Forward = 300
                }
            }
        }
    '
    Add-Type -TypeDefinition $Def

    foreach ($Index in 0..($PlayersIn.Count - 1)) {
        $InPlayer = $Lineup.Where{$_.WebName -eq $PlayersIn[$Index]}[0].psobject.copy()
        $OutPlayer = $Lineup.Where{$_.WebName -eq $PlayersOut[$Index]}[0].psobject.copy()

        foreach ($Property in 'PlayerId', 'Position', 'WebName') {
            $Lineup.Where{$_.PositionNumber -eq $OutPlayer.PositionNumber}[0].$Property = $InPlayer[0].$Property
            $Lineup.Where{$_.PositionNumber -eq $InPlayer.PositionNumber}[0].$Property = $OutPlayer[0].$Property
        }

        $IsSamePosition = $InPlayer.Position -eq $OutPlayer.Position
        $AreBothSubstitutes = $InPlayer.IsSub -and $OutPlayer.IsSub

        if ((-not $IsSamePosition) -and (-not $AreBothSubstitutes)) {
            $Starters, $Substitutes = $Lineup.Where( {-not $_.IsSub}, 'Split' )
            $NewStarters = $Starters | Sort-Object {[enum]::GetNames([FPL.Player.Position]).IndexOf($_)}, {[Fpl.Player.Position]$_.Position + $_.PositionNumber}
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
