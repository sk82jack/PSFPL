function ConvertTo-FplObject {
    <#
    .SYNOPSIS
        Convert an object returned from the FPL API into a more PowerShelly object with a type name
    .DESCRIPTION
        Convert an object returned from the FPL API into a more PowerShelly object with a type name
    .PARAMETER InputObject
        A PowerShell object returned from the FPL API
    .PARAMETER Type
        The type name to give the resulted PowerShell object
    .EXAMPLE
        $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/elements/' -UseBasicParsing
        ConvertTo-FplObject -InputObject $Response -Type 'FplPlayer'
    .LINK
        https://github.com/sk82jack/PSFPL/
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory)]
        [ValidateSet('FplPlayer')]
        [string]
        $Type
    )
    switch ($Type) {
        'FplPlayer' {
            $PositionHash = Get-FplElementType
            $TeamHash = Get-FplClubId
        }
    }

    $TextInfo = (Get-Culture).TextInfo
    foreach ($Object in $InputObject) {
        $Hashtable = @{}
        $Object.psobject.properties | Foreach-Object {
            $Name = $TextInfo.ToTitleCase($_.Name) -replace '_'
            $Value = if ($_.Value -is [string]) {
                $DiacriticName = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($_.Value))
                [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($DiacriticName))
            }
            else {
                $_.Value
            }
            $Hashtable[$Name] = $Value
        }

        switch ($Type) {
            'FplPlayer' {
                $Hashtable['Position'] = $PositionHash[$Object.element_type]
                $Hashtable['Club'] = $TeamHash[$Object.team]
                $Hashtable['Price'] = $Object.now_cost / 10
            }
        }

        $FplObject = [pscustomobject]$Hashtable
        $FplObject.PSObject.TypeNames.Insert(0, $Type)
        $FplObject
    }
}
