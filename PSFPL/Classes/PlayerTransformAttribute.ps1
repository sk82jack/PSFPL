class PlayerTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object]$inputData) {
        $outputData = switch ($inputData) {
            {$_ -is [string]} {
                [PSCustomObject]@{
                    Name = $_
                }
            }
            {$_ -is [int]} {
                [PSCustomObject]@{
                    PlayerId = $_
                }
            }
            {$_ -is [hashtable]} {[PSCustomObject]$_}
            {$_.PSTypeNames[0] -in 'FplPlayer', 'FplLineup'} {$_}
            default {throw 'You must provide a string, integer, hashtable or FPL player object.'}
        }
        foreach ($Player in $outputData) {
            if ($Player.PSTypeNames[0] -in 'FplPlayer', 'FplLineup') {
                continue
            }
            $RequiredProperties = '^Name$', '^PlayerId$'
            $ValidProperties = '^Name$', '^PlayerId$', '^Club$', '^Position$'

            if (-not ($Player.PSObject.Properties.Name -match ($RequiredProperties -join '|'))) {
                throw 'You must specify a Name or PlayerId.'
            }
            if ($Player.PSObject.Properties.Name -notmatch ($ValidProperties -join '|')) {
                throw 'Invalid properties found.'
            }

            if ($Player.Name) {
                $Player.Name = '^{0}$' -f $Player.Name
            }
        }
        return $outputData
    }
}
