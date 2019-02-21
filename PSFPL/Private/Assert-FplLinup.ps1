function Assert-FplLineup {
    [CmdletBinding()]
    param (
        [psobject[]]
        $Lineup
    )

    $Players = @{
        GoalKeepers = $Lineup.Where{$_.Position -eq 'GoalKeeper'}
        Defenders   = $Lineup.Where{$_.Position -eq 'Defender'}
        Midfielders = $Lineup.Where{$_.Position -eq 'Midfielder'}
        Forwards    = $Lineup.Where{$_.Position -eq 'Forward'}
    }

    if ($Players['GoalKeepers'] -and $Players['GoalKeepers'].count -ne 1) {
        Write-Error -Message 'You must only have 1 goalkeeper' -ErrorAction 'Stop'
    }
    if ($Players['Defenders'].count -lt 3) {
        Write-Error -Message 'You must have more than 3 defenders' -ErrorAction 'Stop'
    }
    if ($Players['Midfielders'].count -lt 2) {
        Write-Error -Message 'You must have more than 2 midfielders' -ErrorAction 'Stop'
    }
    if (-not $Players['Forwards']) {
        Write-Error -Message 'You must have at least 1 forward' -ErrorAction 'Stop'
    }
}
