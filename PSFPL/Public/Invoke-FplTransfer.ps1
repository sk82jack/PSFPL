function Invoke-FplTransfer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PlayerTransformAttribute()]
        $PlayersIn,

        [Parameter(Mandatory)]
        [PlayerTransformAttribute()]
        $PlayersOut,

        [Parameter()]
        [ValidateSet('WildCard', 'FreeHit')]
        [string]
        $ActivateChip,

        [Parameter()]
        [switch]
        $Force
    )

    if ($PlayersIn.Count -ne $PlayersOut.Count) {
        Write-Error 'You must provide the same number of players coming into the starting lineup as there are players going out.' -ErrorAction 'Stop'
    }

    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
        Write-Warning 'No existing connection found'
        $Credential = Get-Credential -Message 'Please enter your FPL login details'
        Connect-Fpl -Credential $Credential
    }

    $AllPlayers = Get-FplPlayer
    $Lineup = Get-FplLineup

    $InPlayers = Find-FplPlayer -PlayerTransform $PlayersIn -FplPlayerCollection $AllPlayers
    foreach ($Player in $InPlayers) {
        if ($Player.PlayerId -in $Lineup.PlayerId) {
            $Message = 'The player "{0}" is already in your team' -f $Player.Name
            Write-Error -Message $Message -ErrorAction 'Stop'
        }
    }
    $OutPlayers = Find-FplPlayer -PlayerTransform $PlayersOut -FplPlayerCollection $Lineup

    $Body = @{
        confirmed = $false
        entry     = $FplSessionData['TeamID']
        event     = $FplSessionData['CurrentGW'] + 1
        transfers = [System.Collections.Generic.List[Hashtable]]::new()
        wildcard  = $ActivateChip -eq 'WildCard'
        freehit   = $ActivateChip -eq 'FreeHit'
    }

    foreach ($Index in 0..(@($InPlayers).Count - 1)) {
        $Body.transfers.Add(
            @{
                element_in     = $InPlayers[$Index].PlayerId
                element_out    = $OutPlayers[$Index].PlayerId
                purchase_price = $InPlayers[$Index].Price * 10
                selling_price  = $OutPlayers[$Index].SellingPrice * 10
            }
        )
    }

    $Params = @{
        Uri             = "https://fantasy.premierleague.com/drf/transfers"
        UseBasicParsing = $true
        WebSession      = $FplSessionData['FplSession']
        Method          = 'Post'
        Body            = ($Body | ConvertTo-Json)
        Headers         = @{
            'Content-Type'     = 'application/json; charset=UTF-8'
            'X-CSRFToken'      = $FplSessionData['CsrfToken']
            'X-Requested-With' = 'XMLHttpRequest'
            'Referer'          = 'https://fantasy.premierleague.com/a/squad/transfers'
        }
    }

    try {
        $ConfirmationResponse = Invoke-RestMethod @Params -ErrorAction 'Stop'
    }
    catch {
        $Response = Get-ErrorResponsePayload -ErrorObject $_ | ConvertFrom-Json
        Write-FplError -FplError $Response
    }

    if (-not $Force) {
        Write-Host -Object ('PlayersIn        : {0}' -f ($InPlayers.Name -join ', '))
        Write-Host -Object ('PlayersOut       : {0}' -f ($OutPlayers.Name -join ', '))
        $WriteHostSplat = @{
            Object = 'PointsHit        : {0}' -f $ConfirmationResponse.spent_points
        }
        if ($ConfirmationResponse.spent_points -gt 0) {
            $WriteHostSplat['ForeGroundColor'] = 'Red'
        }
        Write-Host @WriteHostSplat
        Write-Host -Object ('ActivateWildCard : {0}' -f $ConfirmationResponse.wildcard)
        Write-Host -Object ('ActivateFreeHit  : {0}' -f $ConfirmationResponse.freehit)

        $PromptParams = @{
            Title      = 'Confirm Transfers'
            Message    = 'Are you sure you wish to make the transfer(s) listed above?'
            YesMessage = 'Confirm transfers'
            NoMessage  = 'Change transfers'
        }
        $Answer = Read-FplYesNoPrompt @PromptParams

        if ($Answer -eq 1) {
            return
        }
    }

    $Body['confirmed'] = $true
    $Params['Body'] = ($Body | ConvertTo-Json)
    Invoke-RestMethod @Params
}
