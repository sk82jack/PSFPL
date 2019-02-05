# ConvertTo-FplObject

## SYNOPSIS
Convert an object returned from the FPL API into a more PowerShelly object with a type name

## SYNTAX

```
ConvertTo-FplObject [-InputObject] <Object[]> [-Type] <String> [<CommonParameters>]
```

## DESCRIPTION
Convert an object returned from the FPL API into a more PowerShelly object with a type name

## EXAMPLES

### EXAMPLE 1
```
$Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/elements/' -UseBasicParsing
```

ConvertTo-FplObject -InputObject $Response -Type 'FplPlayer'

## PARAMETERS

### -InputObject
A PowerShell object returned from the FPL API

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The type name to give the resulted PowerShell object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

[https://github.com/sk82jack/PSFPL/](https://github.com/sk82jack/PSFPL/)

