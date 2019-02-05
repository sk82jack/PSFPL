# Get-FplFixture

## SYNOPSIS
Retrieves a list of FPL fixtures

## SYNTAX

```
Get-FplFixture [[-Gameweek] <Int32>] [[-Club] <String>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a list of FPL fixtures

## EXAMPLES

### EXAMPLE 1
```
Get-FplFixture
```

This will list all of the fixtures throughout the season

### EXAMPLE 2
```
Get-FplFixture -Gameweek 14
```

This will list the fixtures from gameweek 14

### EXAMPLE 3
```
Get-FplFixture -Club Liverpool
```

This will list all of the fixtures for Liverpool FC

### EXAMPLE 4
```
Get-FplFixture -Club Chelsea -Gameweek 2
```

This will get the Chelsea FC fixture in gameweek 2

## PARAMETERS

### -Gameweek
Retrieve the fixtures from a specified gameweek

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Club
Retrieve the fixtures for a specified club

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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

[https://psfpl.readthedocs.io/en/master/functions/Get-FplFixture](https://psfpl.readthedocs.io/en/master/functions/Get-FplFixture)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplFixture.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplFixture.ps1)

