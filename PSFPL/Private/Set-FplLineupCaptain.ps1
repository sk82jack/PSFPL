function Set-FplLineupCaptain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSTypeName('FplLineup')]
        [PSObject[]]
        $Lineup,

        [Parameter()]
        [PSTypeName('FplLineup')]
        [PSObject]
        $Captain,

        [Parameter()]
        [PSTypeName('FplLineup')]
        [PSObject]
        $ViceCaptain
    )

    if ($Captain) {
        $Lineup.Where{$_.IsCaptain}[0].IsCaptain = $false
        $NewCaptain = $Lineup.Where{$_.PlayerId -eq $Captain.PlayerId}[0]
        if ($NewCaptain.IsSub) {
            Write-Error -Message "You cannot captain a substitute" -ErrorAction 'Stop'
        }
        $NewCaptain.IsCaptain = $true
    }
    if ($ViceCaptain) {
        $Lineup.Where{$_.IsViceCaptain}[0].IsViceCaptain = $false
        $NewViceCaptain = $Lineup.Where{$_.PlayerId -eq $ViceCaptain.PlayerId}[0]
        if ($NewViceCaptain.IsSub) {
            Write-Error -Message "You cannot vice captain a substitute" -ErrorAction 'Stop'
        }
        $NewViceCaptain.IsViceCaptain = $true
    }

    $Lineup
}
