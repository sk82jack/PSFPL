function Invoke-FplTransfer {
    <#
    .SYNOPSIS
        Makes a transfer for the upcoming gameweek
    .DESCRIPTION
        Makes a transfer for the upcoming gameweek
    .PARAMETER PlayersIn
        The player(s) which you wish to transfer into your team.
        This parameter takes multiple types of input:
            It can be passed as a string
            `'Salah'`

            It can be passed as a player ID
            `253`

            It can be passed as a hashtable of properties i.e.
            `@{Name = 'Salah'; Club = 'Liverpool'; Position = 'Midfeilder'; PlayerID = 253}`
            The only allowed properties are Name, Club, Position, PlayerID

            It can be the output of Get-FplPlayer or Get-FplLineup
    .PARAMETER PlayersOut
        The player(s) which you wish to transfer out of your team.
        This parameter takes multiple types of input:
            It can be passed as a string
            `'Salah'`

            It can be passed as a player ID
            `253`

            It can be passed as a hashtable of properties i.e.
            `@{Name = 'Salah'; Club = 'Liverpool'; Position = 'Midfeilder'; PlayerID = 253}`
            The only allowed properties are Name, Club, Position, PlayerID

            It can be the output of Get-FplPlayer or Get-FplLineup
    .PARAMETER ActivateChip
        Use this parameter to activate your Wildcard or Free Hit
    .PARAMETER Force
        By default this function will do a confirmation prompt.
        If you wish to suppress this prompt use the Force parameter.
    .EXAMPLE
        Invoke-FplTransfer -PlayersIn Hazard -PlayersOut Salah

        This example just uses the players names to identify them.
    .EXAMPLE
        Invoke-FplTransfer -PlayersIn Hazard, Robertson -PlayersOut Salah, Alonso

        This example demonstrates passing multiple players to the parameters
    .EXAMPLE
        Invoke-FplTransfer -PlayersIn 122 -PlayersOut 253

        This example uses the player IDs to identify them. 122 is Hazard and 253 is Salah.
        You can find a player ID by doing `Get-FplPlayer Hazard | Select PlayerID`
    .EXAMPLE
        Invoke-FplTransfer -PlayersIn @{Name = 'Sterling'; Club = 'Man City'} -PlayersOut Mane

        This example uses a hashtable to identify Sterling because there is another player in
        the game called Sterling who plays for Spurs.
    .EXAMPLE
        $Hazard = Get-FplPlayer -Name 'Hazard'
        $Salah = Get-FplLineup | Where Name -eq 'Salah'
        Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Salah

        This example shows that you can use the objects directly from Get-FplPlayer and Get-FplLineup
    .EXAMPLE
        Invoke-FplTransfer -PlayersIn Hazard, Robertson -PlayersOut Salah, Alonso -ActivateChip Wildcard

        This example shows how to activate your Wildcard
    .EXAMPLE
        Invoke-FplTransfer -PlayersIn Hazard, Robertson -PlayersOut Salah, Alonso -ActivateChip FreeHit

        This example shows how to activate your Free Hit
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Invoke-FplTransfer
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Invoke-FplTransfer.ps1
    #>

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
        $ActivateChip,

        [Parameter()]
        [switch]
        $Force
    )

    if ($PlayersIn.Count -ne $PlayersOut.Count) {
        Write-Error 'You must provide the same number of players coming into the squad as there are players going out.' -ErrorAction 'Stop'
    }

    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
        Write-Warning 'No existing connection found'
        $Credential = Get-Credential -Message 'Please enter your FPL login details'
        Connect-Fpl -Credential $Credential
    }

    $AllPlayers = ConvertTo-FplObject -InputObject $Script:FplSessionData['Players'] -Type 'FplPlayer'
    $Lineup = Get-FplLineup

    $InPlayers = Find-FplPlayer -PlayerTransform $PlayersIn -FplPlayerCollection $AllPlayers
    foreach ($Player in $InPlayers) {
        if ($Player.PlayerId -in $Lineup.PlayerId) {
            $Message = 'The player "{0}" is already in your team' -f $Player.Name
            Write-Error -Message $Message -ErrorAction 'Stop'
        }
    }
    $OutPlayers = Find-FplPlayer -PlayerTransform $PlayersOut -FplPlayerCollection $Lineup

    $TransfersInfo = Get-FplTransfersInfo
    Assert-FplBankCheck -PlayersIn $InPlayers -PlayersOut $OutPlayers -Bank $TransfersInfo.bank
    $SpentPoints = Get-FplSpentPoints -TransfersCount $InPlayers.Count -TransfersInfo $TransfersInfo

    if (-not $Force) {
        Write-Host -Object ('PlayersIn  : {0}' -f ($InPlayers.Name -join ', '))
        Write-Host -Object ('PlayersOut : {0}' -f ($OutPlayers.Name -join ', '))
        $WriteHostSplat = @{
            Object = 'PointsHit        : {0}' -f $SpentPoints
        }
        if ($SpentPoints -gt 0) {
            $WriteHostSplat['ForeGroundColor'] = 'Red'
        }
        Write-Host @WriteHostSplat
        if ($ActivateChip) {
            Write-Host -Object ('Chip       : {0}' -f $ActivateChip)
        }

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

    $Body = @{
        chip      = $ActivateChip
        entry     = $Script:FplSessionData['TeamID']
        event     = $Script:FplSessionData['CurrentGW'] + 1
        transfers = [System.Collections.Generic.List[Hashtable]]::new()
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
        Uri             = "https://fantasy.premierleague.com/api/transfers/"
        UseBasicParsing = $true
        WebSession      = $FplSessionData['FplSession']
        Method          = 'Post'
        Body            = ($Body | ConvertTo-Json)
        Headers         = @{
            'Content-Type' = 'application/json'
            'Referer'      = 'https://fantasy.premierleague.com/transfers'
        }
    }
    try {
        $Response = Invoke-RestMethod @Params -ErrorAction 'Stop'
    }
    catch {
        $Response = Get-ErrorResponsePayload -ErrorObject $_ | ConvertFrom-Json
        Write-FplError -FplError $Response
    }
}
