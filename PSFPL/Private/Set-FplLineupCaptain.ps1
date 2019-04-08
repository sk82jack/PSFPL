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

    $OriginalCaptain = $Lineup.Where{$_.IsCaptain}[0]
    $OriginalViceCaptain = $Lineup.Where{$_.IsViceCaptain}[0]

    if ($Captain) {
        $OriginalCaptain.IsCaptain = $false
        $NewCaptain = $Lineup.Where{$_.PlayerId -eq $Captain.PlayerId}[0]
        if ($NewCaptain.IsSub) {
            Write-Error -Message "You cannot captain a substitute" -ErrorAction 'Stop'
        }
        if ($NewCaptain.IsViceCaptain) {
            $NewCaptain.IsViceCaptain = $false
            $OriginalCaptain.IsViceCaptain = $true
        }
        $NewCaptain.IsCaptain = $true
    }
    if ($ViceCaptain) {
        $OriginalViceCaptain.IsViceCaptain = $false
        $NewViceCaptain = $Lineup.Where{$_.PlayerId -eq $ViceCaptain.PlayerId}[0]
        if ($NewViceCaptain.IsSub) {
            Write-Error -Message "You cannot vice captain a substitute" -ErrorAction 'Stop'
        }
        if ($NewViceCaptain.IsCaptain) {
            $NewViceCaptain.IsCaptain = $false
            $OriginalViceCaptain.IsCaptain = $true
        }
        $NewViceCaptain.IsViceCaptain = $true
    }

    $Lineup
}
