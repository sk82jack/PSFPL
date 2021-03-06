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
        $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/elements/' -UseBasicParsing
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
        'FplGameweek' {
            $PlayerHash = Get-FplElementId
        }
        'FplFixture' {
            $TeamHash = Get-FplClubId
            $PlayerHash = Get-FplElementId
        }
        'FplLeagueTable' {
            $LeagueName = $InputObject[0].league.name
            $LeagueId = $InputObject[0].league.id
            $InputObject = $InputObject.foreach{$_.standings.results}
        }
        'FplTeam' {
            $TeamHash = Get-FplClubId
        }
        'FplLeague' {
            $InputObject = @($InputObject.classic) + @($InputObject.h2h).where{$_.name -and $_.name -ne 'cup'}
        }
        'FplTeamPlayer' {
            $Players = ConvertTo-FplObject -InputObject $Script:FplSessionData['Players'].Where{$_.id -in $InputObject.element} -Type FplPlayer
        }
        'FplLineup' {
            $Players = ConvertTo-FplObject -InputObject $Script:FplSessionData['Players'].Where{$_.id -in $InputObject.element} -Type FplPlayer
        }
    }

    $TextInfo = (Get-Culture).TextInfo
    foreach ($Object in $InputObject) {
        $Hashtable = [ordered]@{}
        $Object.psobject.properties | ForEach-Object {
            $Name = $TextInfo.ToTitleCase($_.Name) -replace '_' -replace 'Team', 'Club' -replace 'Entry', 'Team' -replace 'Event', 'Gameweek'
            $Value = if ($_.Value -is [string]) {
                if ($PSVersionTable.PSVersion.Major -lt 6) {
                    $DiacriticName = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($_.Value))
                }
                else {
                    $DiacriticName = $_.value
                }
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
                $Hashtable['GameweekId'] = $Hashtable['Id']
                $Hashtable['Gameweek'] = $Hashtable['Id']
                $Hashtable.Remove('Id')
                $Hashtable['DeadlineTime'] = Get-Date $Object.deadline_time
                $Hashtable['BenchBoostPlays'] = $Hashtable['ChipPlays'].Where{$_.chip_name -eq 'bboost'}[0].num_played
                $Hashtable['TripleCaptainPlays'] = $Hashtable['ChipPlays'].Where{$_.chip_name -eq '3xc'}[0].num_played
                $Hashtable.Remove('ChipPlays')
                foreach ($Property in 'MostSelected', 'MostTransferredIn', 'TopElement', 'MostCaptained', 'MostViceCaptained') {
                    $Hashtable["$($Property)Id"] = $Hashtable[$Property]
                    if ($HashTable[$Property]) {
                        $Hashtable[$Property] = $PlayerHash[$HashTable[$Property]]
                    }
                }
                $Hashtable['TopElementPoints'] = if ($Hashtable['TopElementInfo']) {
                    $Hashtable['TopElementInfo'].points
                }
                $Hashtable.Remove('TopElementInfo')
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
                $Hashtable['LeagueId'] = $LeagueId
                $Hashtable['TeamId'] = $Hashtable['Team']
                $Hashtable.Remove('Team')
            }
            'FplTeam' {
                if ($Hashtable['FavouriteClub']) {
                    $Hashtable['FavouriteClub'] = $TeamHash[$Hashtable['FavouriteClub']]
                }
                $Hashtable['TeamId'] = $Hashtable['Id']
                $Hashtable.Remove('Id')
                $Hashtable['JoinedTime'] = Get-Date $Object.joined_time
                $Hashtable.Remove('Leagues')
                $Hashtable['LastDeadlineBank'] = $Hashtable['LastDeadlineBank'] / 10
                $Hashtable['LastDeadlineValue'] = $Hashtable['LastDeadlineValue'] / 10
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
                $Hashtable['Created'] = Get-Date $Hashtable['Created']
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
                $Hashtable['NewsAdded'] = Get-Date $Hashtable['NewsAdded']
            }
            'FplLineup' {
                $Hashtable['PlayerId'] = $Hashtable['Element']
                $Hashtable.Remove('Element')
                $Hashtable['PositionNumber'] = $Hashtable['Position']
                if ($Hashtable.position -le 11) {
                    $Hashtable['PlayingStatus'] = 'Starting'
                    $Hashtable['IsSub'] = $false
                }
                else {
                    $Hashtable['PlayingStatus'] = 'Substitute'
                    $Hashtable['IsSub'] = $true
                }
                $CurrentPlayer = $Players.Where{$_.PlayerId -eq $Hashtable['PlayerId']}
                foreach ($Property in 'Name', 'Position', 'Club') {
                    $Hashtable[$Property] = $CurrentPlayer.$Property
                }
                $Hashtable['SellingPrice'] = $Hashtable['SellingPrice'] / 10
                $Hashtable['PurchasePrice'] = $Hashtable['PurchasePrice'] / 10
            }
        }
        $Hashtable['PsTypeName'] = $Type
        [pscustomobject]$Hashtable
    }
}
