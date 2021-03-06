function Get-FplTeam {
    <#
    .SYNOPSIS
        Retrieve information about an FPL team
    .DESCRIPTION
        Retrieve information about an FPL team either by a specified team ID or get your own team by logging in with Connect-FPL
    .PARAMETER TeamId
        A team ID to retrieve information about
    .EXAMPLE
        Connect-Fpl -Email MyEmail@hotmail.com
        $MyTeam = Get-FplTeam

        Retrieves information about your own team
    .EXAMPLE
        Get-FplTeam -TeamId 12345

        Retrieves information about the team with the ID 12345
    .LINK
        https://psfpl.readthedocs.io/en/master/functions/Get-FplTeam
    .LINK
        https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeam.ps1
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [int]
        $TeamId
    )
    process {
        if ($TeamId -eq 0) {
            if ((-not $Script:FplSessionData) -or (-not $Script:FplSessionData['FplSession'])) {
                Write-Warning 'No existing connection found'
                $Credential = Get-Credential -Message 'Please enter your FPL login details'
                Connect-Fpl -Credential $Credential
            }
            $TeamId = $Script:FplSessionData['TeamID']
        }
        $Response = Invoke-RestMethod -Uri "https://fantasy.premierleague.com/api/entry/$TeamId/" -UseDefaultCredentials
        if ($Response -match 'The game is being updated.') {
            Write-Warning 'The game is being updated. Please try again shortly.'
            return
        }
        ConvertTo-FplObject -InputObject $Response -Type 'FplTeam'
    }
}
