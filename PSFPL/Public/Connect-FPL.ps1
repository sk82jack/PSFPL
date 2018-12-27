function Connect-Fpl {
    <#
    .SYNOPSIS
        Connect to the FPL API using provided login credentials
    .DESCRIPTION
        Connect to the FPL API using provided login credentials
        This is required for some functions which pull data related to your account
    .PARAMETER Credential
        Your FPL credentials that you use to log into https://fantasy.premierleague.com
    .EXAMPLE
        Connect-FPL -Credential myname@email.com
    .LINK
        https://psfpl.readthedocs.io/en/latest/functions/Connect-Fpl
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Connect-FPL.ps1
    #>
    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory)]
        [pscredential]
        $Credential
    )
    $Uri = 'https://users.premierleague.com/accounts/login/'

    $LoginResponse = Invoke-WebRequest -Uri $Uri -SessionVariable 'FplSession' -UseBasicParsing

    $CsrfToken = $LoginResponse.InputFields.Where{$_.name -eq 'csrfmiddlewaretoken'}.value

    $Response = Invoke-WebRequest -Uri $Uri -WebSession $FplSession -Method 'Post' -UseBasicParsing -Body @{
        'csrfmiddlewaretoken' = $CsrfToken
        'login'               = $Credential.UserName
        'password'            = $Credential.GetNetworkCredential().Password
        'app'                 = 'plfpl-web'
        'redirect_uri'        = 'https://fantasy.premierleague.com/a/login'
    }

    if (-not ($Response.Headers.'Set-Cookie' -match 'sessionid=')) {
        Throw 'Invalid credentials'
    }

    $Script:FplSession = $FplSession
}
