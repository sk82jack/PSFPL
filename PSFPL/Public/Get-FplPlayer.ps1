function Get-FplPlayer {
    <#
    .SYNOPSIS
        Retrieve a list of FPL players
    .DESCRIPTION
        Retrieve a list of FPL players
    .PARAMETER Name
        Filter players based on their surname
    .PARAMETER Position
        Filter players based on their position
    .PARAMETER Club
        Filter players based on their club
    .PARAMETER MaxPrice
        Filter players based on their price
    .PARAMETER DreamTeam
        Show the current dream team
    .EXAMPLE
        Get-FplPlayer

        Retrieve all of the FPL players in the game
    .EXAMPLE
        Get-FplPlayer -Name Hazard

        Retrieve all of the FPL players with 'Hazard' in their name
    .EXAMPLE
        Get-FplPlayer -Position Forward -Club 'Man City'

        Retrieve all of the forwards that play for Man City
    .EXAMPLE
        Get-FplPlayer -MaxPrice 5.1

        Retrieve all players priced at £5.1m or lower
    .EXAMPLE
        Get-FplPlayer -DreamTeam

        Retrieve the current dream team
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Get-FplPlayer
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplPlayer.ps1
    #>
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
    Param (
        [Parameter(
            ParameterSetName = 'Filter',
            ValueFromPipeline,
            Position = 0
        )]
        [SupportsWildcards()]
        [string]
        $Name = '*',

        [Parameter(ParameterSetName = 'Filter')]
        [ValidateSet('Forward', 'Midfielder', 'Defender', 'Goalkeeper')]
        [string]
        $Position,

        [Parameter(ParameterSetName = 'Filter')]
        [ValidateSet(
            'Arsenal', 'Bournemouth', 'Brighton', 'Burnley', 'Cardiff', 'Chelsea', 'Crystal Palace',
            'Everton', 'Fulham', 'Huddersfield', 'Leicester', 'Liverpool', 'Man City', 'Man Utd',
            'Newcastle', 'Southampton', 'Spurs', 'Watford', 'West Ham', 'Wolves'
        )]
        [string]
        $Club,

        [Parameter(ParameterSetName = 'Filter')]
        [double]
        $MaxPrice = [int]::MaxValue,

        [Parameter(ParameterSetName = 'DreamTeam')]
        [switch]
        $DreamTeam
    )
    Begin {
        $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/bootstrap-static/' -UseBasicParsing
        if ($Response -match 'The game is being updated.') {
            Write-Warning 'The game is being updated. Please try again shortly.'
            return
        }
        $Players = ConvertTo-FplObject -InputObject $Response.elements -Type 'FplPlayer' | Sort-Object TotalPoints, Price -Descending
    }
    Process {
        $Name = '^{0}$' -f ($Name -replace '\*', '.*')
        $Output = $Players.Where{
            $_.Name -match $Name -and
            $_.Position -match $Position -and
            $_.Club -match $Club -and
            $_.Price -le $MaxPrice
        }
        if ($PSBoundParameters.ContainsKey('MaxPrice')) {
            $Output = $Output | Sort-Object Price, TotalPoints -Descending
        }
        if ($DreamTeam) {
            $SortOrder = 'Goalkeeper', 'Defender', 'Midfielder', 'Forward'
            $Output = $Players.Where{$_.InDreamClub -eq $true} | Sort-Object {$SortOrder.IndexOf($_.Position)}
        }
        $Output
    }
    End {}
}
