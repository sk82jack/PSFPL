# Get-FplPlayer

## SYNOPSIS
Retrieve a list of FPL players

## SYNTAX

### Filter (Default)
```
Get-FplPlayer [[-Name] <String>] [-Position <String>] [-Club <String>] [-MaxPrice <Double>]
 [<CommonParameters>]
```

### DreamTeam
```
Get-FplPlayer [-DreamTeam] [<CommonParameters>]
```

## DESCRIPTION
Retrieve a list of FPL players

## EXAMPLES

### EXAMPLE 1
```
Get-FplPlayer
```

Retrieve all of the FPL players in the game

### EXAMPLE 2
```
Get-FplPlayer -Name Hazard
```

Retrieve all of the FPL players with 'Hazard' in their name

### EXAMPLE 3
```
Get-FplPlayer -Position Forward -Club 'Man City'
```

Retrieve all of the forwards that play for Man City

### EXAMPLE 4
```
Get-FplPlayer -MaxPrice 5.1
```

Retrieve all players priced at £5.1m or lower

### EXAMPLE 5
```
Get-FplPlayer -DreamTeam
```

Retrieve the current dream team

## PARAMETERS

### -Name
Filter players based on their surname

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
```

### -Position
Filter players based on their position

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Club
Filter players based on their club

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxPrice
Filter players based on their price

```yaml
Type: Double
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: 2147483647
Accept pipeline input: False
Accept wildcard characters: False
```

### -DreamTeam
Show the current dream team

```yaml
Type: SwitchParameter
Parameter Sets: DreamTeam
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

[https://psfpl.readthedocs.io/en/master/functions/Get-FplPlayer](https://psfpl.readthedocs.io/en/master/functions/Get-FplPlayer)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplPlayer.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplPlayer.ps1)

