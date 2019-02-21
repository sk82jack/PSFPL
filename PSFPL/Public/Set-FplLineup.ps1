function Set-FplLineup {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateCount(1, 4)]
        [string[]]
        $PlayersIn,

        [Parameter()]
        [ValidateCount(1, 4)]
        [string[]]
        $PlayersOut,

        [Parameter()]
        [string]
        $Captain,

        [Parameter()]
        [string]
        $ViceCaptain
    )

    if (-not ($PlayersIn -or $PlayersOut -or $Captain -or $ViceCaptain)) {
        Write-Error -Message 'Please specify a change to make' -ErrorAction 'Stop'
    }

    if ($PlayersIn.Count -ne $PlayersOut.Count) {
        Write-Error 'You must provide the same number of players coming into the starting lineup as there are players going out' -ErrorAction 'Stop'
    }

    if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
        Write-Warning 'No existing connection found'
        $Credential = Get-Credential -Message 'Please enter your FPL login details'
        Connect-Fpl -Credential $Credential
    }

    $Lineup = Get-FplLineup

    $PlayerNames = $PlayersIn + $PlayersOut + @($Captain, $ViceCaptain) | Where-Object {$_}
    foreach ($Name in $PlayerNames) {
        if ($Name -notin $Lineup.WebName) {
            Write-Error -Message "There is no player with the name '$Name' in your team" -ErrorAction 'Stop'
        }
    }

    if ($PlayersIn -and $PlayersOut) {
        $Lineup = Invoke-FplLineupSwap -Lineup $Lineup -PlayersIn $PlayersIn -PlayersOut $PlayersOut
    }

    $CaptainParams = @{
        Lineup = $Lineup
    }
    if ($Captain) {$CaptainParams['Captain'] = $Captain}
    if ($ViceCaptain) {$CaptainParams['ViceCaptain'] = $ViceCaptain}
    if ($CaptainParams) {$Lineup = Set-FplLineupCaptain @CaptainParams}

    Assert-FplLineup -Lineup $Lineup.Where{-not $_.IsSub}

    $Body = [PSCustomObject]@{
        picks = $Lineup.Foreach{
            @{
                element         = $_.PlayerId
                position        = $_.PositionNumber
                is_captain      = $_.IsCaptain
                is_vice_captain = $_.IsViceCaptain
            }
        }
    }
    $TeamId = $Script:FplSessionData['TeamID']
    $Params = @{
        Uri                   = "https://fantasy.premierleague.com/drf/my-team/$TeamId/"
        UseDefaultCredentials = $true
        WebSession            = $FplSessionData['FplSession']
        Method                = 'Post'
        Body                  = ($Body | ConvertTo-Json)
        Headers               = @{
            'Content-Type'     = 'application/json; charset=UTF-8'
            'X-CSRFToken'      = $FplSessionData['CsrfToken']
            'X-Requested-With' = 'XMLHttpRequest'
            'Referer'          = 'https://fantasy.premierleague.com/a/team/my'
        }
    }

    $Response = Invoke-RestMethod @Params
}
