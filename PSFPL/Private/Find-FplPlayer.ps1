Function Find-FplPlayer {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSObject[]]
        $PlayerTransform,

        [Parameter()]
        [PSObject[]]
        $FplPlayerCollection
    )

    foreach ($Player in $PlayerTransform) {
        if ($Player.PSTypeNames -contains 'FplLineup') {
            $Player
            continue
        }
        $SearchName = $Player.Name -Replace '[.^$]'
        if ($Player.PlayerId) {
            $PlayerObj = $FplPlayerCollection.Where{$_.PlayerId -eq $Player.PlayerId}
        }
        else {
            $PlayerObj = $FplPlayerCollection.Where{
                $_.Name -match $Player.Name -and
                $_.Club -match $Player.Club -and
                $_.Position -match $Player.Position
            }
            if ($PlayerObj.Count -gt 1) {
                $Message = 'Multiple players found that match "{0}"' -f $SearchName
                Write-Error -Message $Message -ErrorAction 'Stop'
            }
        }

        if (-not $PlayerObj) {
            if ($FplPlayerCollection.Count -eq 15) {
                $Message = 'The player "{0}" cannot be found in your team.' -f $SearchName
            }
            else {
                $Message = 'The player "{0}" does not exist with the specified properties.' -f $SearchName
            }

            Write-Error -Message $Message -ErrorAction 'Stop'
        }

        $PlayerObj
    }
}
