function Get-FplClubId {
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/teams' -UseBasicParsing
    $Hashtable = @{}
    foreach ($Club in $Response) {
        $Hashtable[$Club.id] = $Club.name
    }
    $Hashtable
}
