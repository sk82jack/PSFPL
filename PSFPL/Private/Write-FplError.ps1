function Write-FplError {
    [CmdletBinding()]
    param (
        [CmdletBinding()]
        $FplError
    )

    if ($FplError.details) {
        $FplError = $FplError.details
    }
    $Message = if ($FplError.non_form_errors) {
        if ([string]$FplError.non_form_errors -match 'TXFER_NEGATIVE_BANK::Negative bank balance -(\d+) is not allowed') {
            'TXFER_NEGATIVE_BANK::Negative bank balance -{0}{1:n1}m is not allowed.' -f [char]163, ([int]$Matches[1] / 10)
        }
        else {
            [string]$FplError.non_form_errors
        }
    }
    elseif ($FplError.non_field_errors) {
        [string]$FplError.non_field_errors
    }
    elseif ($FplError.errors) {
        switch ($FplError.errors) {
            {$_.freehit} {[string]$_.freehit}
            {$_.wildcard} {[string]$_.wildcard}
            default {[string]$_}
        }
    }
    else {
        [string]$_
    }

    $Message = $Message -replace '.*::(.*)', '$1'
    Write-Error -Message $Message -ErrorAction 'Stop'
}
