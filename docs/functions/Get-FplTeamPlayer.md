# Get-FplTeamPlayer

## SYNOPSIS
Retrieves the player information within a team from a certain gameweek.

## SYNTAX

```
Get-FplTeamPlayer [[-TeamId] <Int32>] [[-Gameweek] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the player information within a team from a certain gameweek.
If no team ID or gameweek is supplied it will request to authenticate to get the users team and current gameweek.

## EXAMPLES

### EXAMPLE 1
```
Get-FplTeamPlayer
```

This will prompt the user to supply credentials and return the user's player information from the current gameweek

### EXAMPLE 2
```
Get-FplTeamPlayer -TeamID 12345
```

This will get the player information for the team with ID 12345 from the current gameweek

### EXAMPLE 3
```
Get-FplTeamPlayer -TeamID 12345 -Gameweek 12
```

This will get the player information for the team with ID 12345 from gameweek 12

## PARAMETERS

### -TeamId
The ID of the team to retrieve the player information

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Gameweek
The gameweek of which to retrieve the player information from

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
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

[https://psfpl.readthedocs.io/en/latest/functions/Get-FplTeamPlayer](https://psfpl.readthedocs.io/en/latest/functions/Get-FplTeamPlayer)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeamPlayer.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeamPlayer.ps1)

