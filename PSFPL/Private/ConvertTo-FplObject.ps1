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
        [ValidateSet(
            'FplPlayer', 'FplGameweek', 'FplFixture', 'FplLeagueTable', 'FplTeam',
            'FplLeague', 'FplTeamPlayer', 'FplLineup'
        )]
        [string]
        $Type
    )
    switch ($Type) {
        'FplPlayer' {
            $PositionHash = Get-FplElementType
            $TeamHash = Get-FplClubId
        }
        'FplFixture' {
            $TeamHash = Get-FplClubId
            $PlayerHash = Get-FplElementId
        }
        'FplLeagueTable' {
            $LeagueName = $InputObject[0].league.name
            $InputObject = $InputObject.foreach{$_.standings.results}
        }
        'FplTeam' {
            $TeamHash = Get-FplClubId
        }
        'FplLeague' {
            $InputObject = @($InputObject.classic) + @($InputObject.h2h).where{$_.name -ne 'cup'}
        }
        'FplTeamPlayer' {
            $Players = Get-FplPlayer
        }
        'FplLineup' {
            $Players = Get-FplPlayer
        }
    }

    $TextInfo = (Get-Culture).TextInfo
    foreach ($Object in $InputObject) {
        $Hashtable = [ordered]@{}
        $Object.psobject.properties | ForEach-Object {
            $Name = $TextInfo.ToTitleCase($_.Name) -replace '_' -replace 'Team', 'Club' -replace 'Entry', 'Team' -replace 'Event', 'Gameweek'
            $Value = if ($_.Value -is [string]) {
                $DiacriticName = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($_.Value))
                [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($DiacriticName)).trim()
            }
            else {
                $_.Value
            }
            $Hashtable[$Name] = $Value
        }

    switch ($Type) {
        'FplPlayer' {
            $Hashtable['PlayerId'] = $Hashtable['Id']
            $Hashtable.Remove('Id')
            $Hashtable['Name'] = $Hashtable['WebName']
            $Hashtable['Position'] = $PositionHash[$Object.element_type]
            $Hashtable['ClubId'] = $Hashtable['Club']
            $Hashtable['Club'] = $TeamHash[$Hashtable['Club']]
            $Hashtable['Price'] = $Object.now_cost / 10
        }
        'FplGameweek' {
            $Hashtable['Gameweek'] = $Hashtable['Id']
            $Hashtable.Remove('Id')
            $Hashtable['DeadlineTime'] = Get-Date $Object.deadline_time
        }
        'FplFixture' {
            $Hashtable['FixtureId'] = $Hashtable['Id']
            $Hashtable.Remove('Id')
            $Hashtable['DeadlineTime'] = try {
                Get-Date $Object.deadline_time
            }
            catch {
                'tbc'
            }
            $HashTable['KickoffTime'] = try {
                Get-Date $Object.kickoff_time
            }
            catch {
                'tbc'
            }
            if (-not $Hashtable['Gameweek']) {
                $Hashtable['Gameweek'] = 'tbc'
            }
            $Hashtable['ClubA'] = $TeamHash[$Object.team_a]
            $Hashtable['ClubH'] = $TeamHash[$Object.team_h]
            $Hashtable['Stats'] = foreach ($Stat in $Hashtable['Stats']) {
                $StatType = $TextInfo.ToTitleCase($Stat.PSObject.Properties.Name)
                foreach ($Letter in 'a', 'h') {
                    $Club = 'Club{0}' -f $Letter.ToUpper()
                    foreach ($Item in $Stat.$StatType.$Letter) {
                        [pscustomobject]@{
                            'PlayerId'   = $Item.element
                            'PlayerName' = $PlayerHash[$Item.element]
                            'StatType'   = $StatType -replace '_'
                            'StatValue'  = $Item.value
                            'ClubName'   = $Hashtable[$club]
                        }
                    }
                }
            }
        }
        'FplLeagueTable' {
            $Hashtable['LeagueName'] = $LeagueName
            $Hashtable['LeagueId'] = $Hashtable['League']
            $Hashtable.Remove('League')
            $Hashtable['TeamId'] = $Hashtable['Team']
            $Hashtable.Remove('Team')
        }
        'FplTeam' {
            $Hashtable['Bank'] = $Hashtable['Bank'] / 10
            $Hashtable['Value'] = $Hashtable['Value'] / 10
            if ($Hashtable['FavouriteClub']) {
                $Hashtable['FavouriteClub'] = $TeamHash[$Hashtable['FavouriteClub']]
            }
            $Hashtable['TeamId'] = $Hashtable['Id']
            $Hashtable.Remove('Id')
            $Hashtable['PlayerId'] = $Hashtable['Player']
            $Hashtable.Remove('Player')
        }
        'FplLeague' {
            $Hashtable['LeagueId'] = $Hashtable['Id']
            $Hashtable.Remove('Id')
            $Hashtable['LeagueType'] = switch ($Hashtable['LeagueType']) {
                'c' {'Public'}
                's' {'Global'}
                'x' {'Private'}
            }
            $Hashtable['Scoring'] = switch ($Hashtable['Scoring']) {
                'c' {'Classic'}
                'h' {'H2H'}
            }
        }
        'FplTeamPlayer' {
            $Hashtable['PlayerId'] = $Hashtable['Element']
            $Hashtable.Remove('Element')
            if ($Hashtable.position -le 11) {
                $Hashtable['PlayingStatus'] = 'Starting'
            }
            else {
                $Hashtable['PlayingStatus'] = 'Substitute'
            }

            $CurrentPlayer = $Players.Where{$_.PlayerId -eq $Hashtable['PlayerId']}
            foreach ($Property in (Get-Member -InputObject $CurrentPlayer[0] -MemberType 'NoteProperty').Name) {
                $Hashtable[$Property] = $CurrentPlayer.$Property
            }
            $Hashtable['Points'] = $CurrentPlayer.GameweekPoints * $Hashtable['Multiplier']
            $Hashtable.Remove('Multiplier')

        }
        'FplLineup' {
            $Hashtable['PlayerId'] = $Hashtable['Element']
            $Hashtable.Remove('Element')
            $Hashtable['PositionNumber'] = $Hashtable['Position']
            if ($Hashtable.position -le 11) {
                $Hashtable['PlayingStatus'] = 'Starting'
            }
            else {
                $Hashtable['PlayingStatus'] = 'Substitute'
            }
            $CurrentPlayer = $Players.Where{$_.PlayerId -eq $Hashtable['PlayerId']}
            foreach ($Property in 'Name', 'Position', 'Club') {
                $Hashtable[$Property] = $CurrentPlayer.$Property
            }
            $Hashtable['SellingPrice'] = $Hashtable['SellingPrice'] / 10
        }
    }
    $Hashtable['PsTypeName'] = $Type
    [pscustomobject]$Hashtable
}
}
