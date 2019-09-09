# Invoke-FplTransfer

## SYNOPSIS
Makes a transfer for the upcoming gameweek

## SYNTAX

```
Invoke-FplTransfer [-PlayersIn] <Object> [-PlayersOut] <Object> [[-ActivateChip] <Object>] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION
Makes a transfer for the upcoming gameweek

## EXAMPLES

### EXAMPLE 1
```
Invoke-FplTransfer -PlayersIn Hazard -PlayersOut Salah
```

This example just uses the players names to identify them.

### EXAMPLE 2
```
Invoke-FplTransfer -PlayersIn Hazard, Robertson -PlayersOut Salah, Alonso
```

This example demonstrates passing multiple players to the parameters

### EXAMPLE 3
```
Invoke-FplTransfer -PlayersIn 122 -PlayersOut 253
```

This example uses the player IDs to identify them.
122 is Hazard and 253 is Salah.
You can find a player ID by doing \`Get-FplPlayer Hazard | Select PlayerID\`

### EXAMPLE 4
```
Invoke-FplTransfer -PlayersIn @{Name = 'Sterling'; Club = 'Man City'} -PlayersOut Mane
```

This example uses a hashtable to identify Sterling because there is another player in
the game called Sterling who plays for Spurs.

### EXAMPLE 5
```
$Hazard = Get-FplPlayer -Name 'Hazard'
```

$Salah = Get-FplLineup | Where Name -eq 'Salah'
Invoke-FplTransfer -PlayersIn $Hazard -PlayersOut $Salah

This example shows that you can use the objects directly from Get-FplPlayer and Get-FplLineup

### EXAMPLE 6
```
Invoke-FplTransfer -PlayersIn Hazard, Robertson -PlayersOut Salah, Alonso -ActivateChip Wildcard
```

This example shows how to activate your Wildcard

### EXAMPLE 7
```
Invoke-FplTransfer -PlayersIn Hazard, Robertson -PlayersOut Salah, Alonso -ActivateChip FreeHit
```

This example shows how to activate your Free Hit

## PARAMETERS

### -PlayersIn
The player(s) which you wish to transfer into your team.
This parameter takes multiple types of input:
    It can be passed as a string
    \`'Salah'\`

    It can be passed as a player ID
    \`253\`

    It can be passed as a hashtable of properties i.e.
    \`@{Name = 'Salah'; Club = 'Liverpool'; Position = 'Midfeilder'; PlayerID = 253}\`
    The only allowed properties are Name, Club, Position, PlayerID

    It can be the output of Get-FplPlayer or Get-FplLineup

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlayersOut
The player(s) which you wish to transfer out of your team.
This parameter takes multiple types of input:
    It can be passed as a string
    \`'Salah'\`

    It can be passed as a player ID
    \`253\`

    It can be passed as a hashtable of properties i.e.
    \`@{Name = 'Salah'; Club = 'Liverpool'; Position = 'Midfeilder'; PlayerID = 253}\`
    The only allowed properties are Name, Club, Position, PlayerID

    It can be the output of Get-FplPlayer or Get-FplLineup

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActivateChip
Use this parameter to activate your Wildcard or Free Hit

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
By default this function will do a confirmation prompt.
If you wish to suppress this prompt use the Force parameter.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://psfpl.readthedocs.io/en/master/functions/Invoke-FplTransfer](https://psfpl.readthedocs.io/en/master/functions/Invoke-FplTransfer)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Invoke-FplTransfer.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Invoke-FplTransfer.ps1)

