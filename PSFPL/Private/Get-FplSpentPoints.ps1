function Get-FplSpentPoints {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]
        $TransfersCount,

        [Parameter(Mandatory)]
        $TransfersInfo
    )

    if ($TransfersInfo.status -ne 'cost') {
        $SpentPoints = 0
    }
    else {
        $TransfersOverLimit = $TransfersCount - $TransfersInfo.limit + $TransfersInfo.made
        if ($TransfersOverLimit -gt 0) {
            $SpentPoints = $TransfersOverLimit * $TransfersInfo.cost
        }
        else {
            $SpentPoints = 0
        }
    }

    $SpentPoints
}
