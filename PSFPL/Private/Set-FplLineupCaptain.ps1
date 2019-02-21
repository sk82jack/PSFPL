function Set-FplLineupCaptain {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSObject[]]
        $Lineup,

        [Parameter()]
        [string]
        $Captain,

        [Parameter()]
        [string]
        $ViceCaptain
    )

    if ($Captain) {
        $Lineup.Where{$_.IsCaptain}[0].IsCaptain = $false
        $NewCaptain = $Lineup.Where{$_.WebName -eq $Captain}[0]
        if ($NewCaptain.IsSub) {
            Write-Error -Message "You cannot captain a substitute" -ErrorAction 'Stop'
        }
        $NewCaptain.IsCaptain = $true
    }
    if ($ViceCaptain) {
        $Lineup.Where{$_.IsViceCaptain}[0].IsViceCaptain = $false
        $NewViceCaptain = $Lineup.Where{$_.WebName -eq $ViceCaptain}[0]
        if ($NewViceCaptain.IsSub) {
            Write-Error -Message "You cannot vice captain a substitute" -ErrorAction 'Stop'
        }
        $NewViceCaptain.IsViceCaptain = $true
    }

    $Lineup
}
