function Get-FplPlayer {
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
    Param (
        [Parameter(
            ParameterSetName = 'Filter',
            ValueFromPipeline
        )]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Filter')]
        [ValidateSet('Forward', 'Midfeilder', 'Defender', 'Goalkeeper')]
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
        $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/elements/' -UseBasicParsing
        $Players = ConvertTo-FplObject -InputObject $Response -Type 'FplPlayer' | Sort-Object TotalPoints, Price -Descending
    }
    Process {
        $Output = $Players.Where{
            $_.WebName -match $Name -and
            $_.Position -match $Position -and
            $_.Club -match $Club -and
            $_.Price -le $MaxPrice
        }
        if ($PSBoundParameters.ContainsKey('MaxPrice')) {
            $Output = $Output | Sort-Object Price, TotalPoints -Descending
        }
        if ($DreamTeam) {
            $SortOrder = 'Goalkeeper', 'Defender', 'Midfielder', 'Forward'
            $Output = $Players.Where{$_.InDreamTeam -eq $true} | Sort-Object {$SortOrder.IndexOf($_.Position)}
        }
        $Output
    }
    End {}
}
