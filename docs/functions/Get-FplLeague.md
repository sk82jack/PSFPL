# Get-FplLeague

## SYNOPSIS
Lists the leagues that a team is a member of.

## SYNTAX

```
Get-FplLeague [[-TeamId] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Lists the leagues that a team is a member of given a team ID.
If no team ID is specified then it will list the leagues for your team.
This requires an existing connection which can be created with Connect-Fpl.
If there is no existing connection found it will prompt for credentials.

## EXAMPLES

### EXAMPLE 1
```
Get-FplLeague
```

This will list the leagues that your team is in.

### EXAMPLE 2
```
Get-FplLeague -TeamId 12345
```

This will list the leagues that the team with the team ID of 12345 is in.

## PARAMETERS

### -TeamId
The team ID of the team to list the leagues of.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://psfpl.readthedocs.io/en/latest/functions/Get-FplLeague](https://psfpl.readthedocs.io/en/latest/functions/Get-FplLeague)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeague.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplLeague.ps1)

