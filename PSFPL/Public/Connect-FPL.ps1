function Connect-FPL {
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
        https://github.com/sk82jack/PSFPL/
    #>
    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory)]
        [pscredential]
        $Credential
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Uri = 'https://users.premierleague.com/accounts/login/'

    $LoginResponse = Invoke-WebRequest -Uri $Uri -SessionVariable 'FplSession' -UseBasicParsing
    $Script:FPLSession = $FplSession

    $CsrfToken = $LoginResponse.InputFields.Where{$_.name -eq 'csrfmiddlewaretoken'}.value

    $Response = Invoke-WebRequest -Uri $Uri -WebSession $FplSession -Method 'Post' -UseBasicParsing -Body @{
        'csrfmiddlewaretoken' = $CsrfToken
        'login'               = $Credential.UserName
        'password'            = $Credential.GetNetworkCredential().Password
        'app'                 = 'plfpl-web'
        'redirect_uri'        = 'https://fantasy.premierleague.com/a/login'
    }

    if ($Response.Headers.'Set-Cookie' -notmatch 'sessionid=') {
        Throw 'Invalid credentials'
    }
}
