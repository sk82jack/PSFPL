function Set-FplLineup {
    <#
    .SYNOPSIS
        Set your team lineup for the upcoming gameweek
    .DESCRIPTION
        Set your team lineup for the upcoming gameweek
    .PARAMETER PlayersIn
        The players which you wish to bring in to the starting XI.
        Alternatively, if you are just swapping the order of players on your bench then use PlayersIn for one bench player and PlayersOut for the other
    .PARAMETER PlayersOut
        The players you wish to remove from the starting XI.
        Alternatively, if you are just swapping the order of players on your bench then use PlayersIn for one bench player and PlayersOut for the other
    .PARAMETER Captain
        The player who you wish to be Captain of your team
    .PARAMETER ViceCaptain
        The player who you wish to be ViceCaptain of your team
    .EXAMPLE
        Set-FplLineup -PlayersIn Son -PlayersOut Pogba

        This will remove Pogba from the starting XI and swap him with Son
    .EXAMPLE
        Set-FplLineup -PlayersIn Son, Rashford, Alexander-Arnold -PlayersOut Ings, Diop, Digne

        This will remove Ings, Diop and Digne from the starting XI and swap them with Son, Rashford and Alexander-Arnold
    .EXAMPLE
        Set-FplLineup -Captain Salah

        This will set your captain for the upcoming gameweek to Salah
    .EXAMPLE
        Set-FplLineup -ViceCaptain Sterling

        This will set your vice captain for the upcoming gameweek to Sterling
    .EXAMPLE
        Set-FplLinup -PlayersIn Sane -PlayersOut Diop -Captain Sane -ViceCaptain Pogba

        This will swap out Diop for Sane in your starting XI and then set Sane to be the captain and Pogba to be the vice captain
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Set-FplLineup
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Set-FplLineup.ps1
    #>

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
