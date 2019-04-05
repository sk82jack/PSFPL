function Get-FplGameweek {
    <#
    .SYNOPSIS
        Retrieves a list of FPL gameweeks
    .DESCRIPTION
        Retrieves a list of FPL gameweeks
    .PARAMETER Gameweek
        Retrieve a specific gameweek by it's number
    .Parameter Current
        Retrieves the current gameweek
    .EXAMPLE
        Get-FplGameweek

        This will list all of the gameweeks
    .EXAMPLE
        Get-FplGameweek -Gameweek 14

        This will list only gameweek 14
    .EXAMPLE
        9 | Get-FplGameweek

        This will list only gameweek 9
    .EXAMPLE
        Get-FplGameweek -Current

        This will list only the current gameweek
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Get-FplGameweek
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
    if ($Response -match 'The game is being updated.') {
        Write-Warning 'The game is being updated. Please try again shortly.'
        return
    }
    $Gameweeks = ConvertTo-FplObject -InputObject $Response -Type 'FplGameweek'

    if ($Current) {
        $Gameweeks.Where{$_.IsCurrent}
    }
    elseif ($Gameweek -gt 0) {
        $Gameweeks.Where{$_.Gameweek -eq $Gameweek}
    }
    else {
        $Gameweeks
    }
}
