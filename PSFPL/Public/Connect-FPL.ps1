function Connect-Fpl {
    <#
    .SYNOPSIS
        Connect to the FPL API using provided login credentials
    .DESCRIPTION
        Connect to the FPL API using provided login credentials
        This is required for some functions which pull data related to your account
    .PARAMETER Credential
        Your FPL credentials that you use to log into https://fantasy.premierleague.com
    .PARAMETER Force
        Create a connection regardless of whether there is already an existing connection
    .EXAMPLE
        Connect-FPL -Credential myname@email.com
    .EXAMPLE
        Connect-FPL -Credential myname@email.com -Force
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Connect-Fpl
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Connect-FPL.ps1
    #>
    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory)]
        [pscredential]
        $Credential,

        [Parameter()]
        [switch]
        $Force
    )

    if ($Script:FplSessionData -and $Script:FplSessionData['FplSession'] -and (-not $Force)) {
        Write-Warning "A connection already exists. Use the Force parameter to connect."
        return
    }

    $Uri = 'https://users.premierleague.com/accounts/login/'
    $null = Invoke-WebRequest -Uri $Uri -SessionVariable 'FplSession' -Method 'Post' -UseBasicParsing -Body @{
        'login'        = $Credential.UserName
        'password'     = $Credential.GetNetworkCredential().Password
        'app'          = 'plfpl-web'
        'redirect_uri' = 'https://fantasy.premierleague.com/a/login'
    }

    $ManagerInfo = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/me/' -UseBasicParsing -WebSession $FplSession

    if (-not ($ManagerInfo.player)) {
        Throw 'Invalid credentials'
    }

    $Bootstrap = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/api/bootstrap-static/' -UseBasicParsing -WebSession $FplSession
    $TeamInfo = Invoke-RestMethod -Uri ('https://fantasy.premierleague.com/api/entry/{0}/' -f $ManagerInfo.player.entry) -UseBasicParsing -WebSession $FplSession

    $Script:FplSessionData = @{
        FplSession   = $FplSession
        TeamID       = $ManagerInfo.player.entry
        CurrentGW    = [int]$TeamInfo.current_event
        ElementTypes = $Bootstrap.element_types
        Clubs        = $Bootstrap.teams
        Players      = $Bootstrap.elements
    }
}
