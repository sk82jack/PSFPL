function Get-FplClubId {
    <#
    .SYNOPSIS
        Retrieves a hashtable of club IDs to club names
    .DESCRIPTION
        Retrieves a hashtable of club IDs to club names
    .EXAMPLE
        Get-FplClubId
    .LINK
        https://github.com/sk82jack/PSFPL/
    #>
    [CmdletBinding()]
    param ()
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/teams/' -UseBasicParsing
    $Hashtable = @{}
    foreach ($Club in $Response) {
        $Hashtable[$Club.id] = $Club.name
    }
    $Hashtable
}
