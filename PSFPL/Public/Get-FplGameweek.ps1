function Get-FplGameweek {
    <#
    .SYNOPSIS
        Retrieves a list of FPL gameweeks
    .DESCRIPTION
        Retrieves a list of FPL gameweeks
    .PARAMETER Gameweek
        Retrieve a specific gameweek by it's number
    .EXAMPLE
        Get-FplGameweek

        This will list all of the gameweeks
    .EXAMPLE
        Get-FplGameweek -Gameweek 14

        This will list only gameweek 14
    .LINK
        https://psfpl.readthedocs.io/en/latest/functions/Get-FplGameweek
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplGameweek.ps1
    #>
    [CmdletBinding(DefaultParameterSetName = 'Gameweek')]
    param (
        [Parameter(
            ParameterSetName = 'Gameweek',
            ValueFromPipeline
        )]
        [int]
        $Gameweek,

        [Parameter(ParameterSetName = 'Current')]
        [switch]
        $Current
    )

    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/events/' -UseBasicParsing
    $Gameweeks = ConvertTo-FplObject -InputObject $Response -Type 'FplGameweek'

    if ($Current) {
        $Gameweeks.Where{$_.IsCurrent}
    }
    elseif ($Gameweek -gt 0) {
        $Gameweeks.Where{$_.Id -eq $Gameweek}
    }
    else {
        $Gameweeks
    }
}
