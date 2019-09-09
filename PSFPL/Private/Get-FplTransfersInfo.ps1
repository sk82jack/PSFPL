function Get-FplTransfersInfo {
    [CmdletBinding()]
    param ()

    $Uri = 'https://fantasy.premierleague.com/api/my-team/{0}/' -f $Script:FplSessionData['TeamID']
    $Result = Invoke-RestMethod -Uri $Uri -UseBasicParsing -WebSession $Script:FplSessionData['FplSession']
    $Result.transfers
}
