function Assert-FplBankCheck {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSObject[]]
        $PlayersIn,

        [Parameter(Mandatory)]
        [PSObject[]]
        $PlayersOut,

        [Parameter(Mandatory)]
        [int]
        $Bank
    )

    $PlayersInPrice = $PlayersIn.Price | Measure-Object -Sum
    $PlayersOutPrice = $PlayersOut.SellingPrice | Measure-Object -Sum
    $PriceDifference = $PlayersOutPrice.Sum - $PlayersInPrice.Sum
    $Balance = $Bank + [int]($PriceDifference * 10)
    if ($Balance -le 0) {
        $Message = 'Negative bank balance -{0}{1}m is not allowed' -f [char]163, - ($Balance / 10)
        Write-Error -Message $Message -ErrorAction 'Stop'
    }
}
