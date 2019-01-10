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
        [ValidateSet('FplPlayer', 'FplGameweek', 'FplFixture', 'FplLeagueTable', 'FplTeam', 'FplLeague')]
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
            $InputObject = $InputObject.classic + @($InputObject.h2h).where{$_.name -ne 'cup'}
        }
    }

    $TextInfo = (Get-Culture).TextInfo
    foreach ($Object in $InputObject) {
        $Hashtable = [ordered]@{}
        $Object.psobject.properties | Foreach-Object {
            $Name = $TextInfo.ToTitleCase($_.Name) -replace '_' -replace 'Team', 'Club' -replace 'Entry', 'Team' -replace 'Event', 'Gameweek'
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
                $Hashtable['ClubId'] = $Object.Club
                $Hashtable['Club'] = $TeamHash[$Object.team]
                $Hashtable['Price'] = $Object.now_cost / 10
            }
            'FplGameweek' {
                $Hashtable['DeadlineTime'] = Get-Date $Object.deadline_time
            }
            'FplFixture' {
                $Hashtable['DeadlineTime'] = Get-Date $Object.deadline_time
                $HashTable['KickoffTime'] = Get-Date $Object.kickoff_time
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
                $Hashtable['FavouriteClub'] = $TeamHash[$Hashtable['FavouriteClub']]
                $Hashtable['TeamId'] = $Hashtable['Id']
                $Hashtable.Remove('Id')
                $Hashtable['PlayerId'] = $Hashtable['Player']
                $Hashtable.Remove('Player')
            }
            'FplLeague' {}
        }
        $Hashtable['PsTypeName'] = $Type
        [pscustomobject]$Hashtable
    }
}
