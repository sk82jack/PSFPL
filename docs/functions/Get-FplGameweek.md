# Get-FplGameweek

## SYNOPSIS
Retrieves a list of FPL gameweeks

## SYNTAX

### Gameweek (Default)
```
Get-FplGameweek [-Gameweek <Int32>] [<CommonParameters>]
```

### Current
```
Get-FplGameweek [-Current] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a list of FPL gameweeks

## EXAMPLES

### EXAMPLE 1
```
Get-FplGameweek
```

This will list all of the gameweeks

### EXAMPLE 2
```
Get-FplGameweek -Gameweek 14
```

This will list only gameweek 14

### EXAMPLE 3
```
9 | Get-FplGameweek
```

This will list only gameweek 9

### EXAMPLE 4
```
Get-FplGameweek -Current
```

This will list only the current gameweek

## PARAMETERS

### -Gameweek
Retrieve a specific gameweek by it's number

```yaml
Type: Int32
Parameter Sets: Gameweek
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Current
Retrieves the current gameweek

```yaml
Type: SwitchParameter
Parameter Sets: Current
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://psfpl.readthedocs.io/en/master/functions/Get-FplGameweek](https://psfpl.readthedocs.io/en/master/functions/Get-FplGameweek)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplGameweek.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplGameweek.ps1)

