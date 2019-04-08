# Get-FplLeagueTable

## SYNOPSIS
Retrieves an FPL league table

## SYNTAX

### Default (Default)
```
Get-FplLeagueTable -LeagueId <Int32> -Type <String> [<CommonParameters>]
```

### PipelineInput
```
Get-FplLeagueTable -League <Object> [<CommonParameters>]
```

## DESCRIPTION
Retrieves an FPL league table given a league ID and league type

## EXAMPLES

### EXAMPLE 1
```
Get-FplLeagueTable -Id 12345 -Type Classic
```

This will show the league standings for the classic league of ID 12345

### EXAMPLE 2
```
Get-FplLeague | Where Name -eq 'My League' | Get-FplLeagueTable
```

This will get the league standings for the league that your team is in called 'My League'

## PARAMETERS

### -LeagueId
An FPL league Id

```yaml
Type: Int32
Parameter Sets: Default
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
An FPL league type.
This can either be 'Classic' or 'HeadToHead'

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -League
This parameter allows you to pass in an FplLeague object directly which can be retrieved from Get-FplLeague

```yaml
Type: Object
Parameter Sets: PipelineInput
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://psfpl.readthedocs.io/en/master/functions/Get-FplLeagueTable](https://psfpl.readthedocs.io/en/master/functions/Get-FplLeagueTable)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeagueTable.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeagueTable.ps1)

