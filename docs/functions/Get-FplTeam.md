# Get-FplTeam

## SYNOPSIS
Retrieve information about an FPL team

## SYNTAX

```
Get-FplTeam [[-TeamId] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Retrieve information about an FPL team either by a specified team ID or get your own team by logging in with Connect-FPL

## EXAMPLES

### EXAMPLE 1
```
Connect-Fpl -Email MyEmail@hotmail.com
```

$MyTeam = Get-FplTeam

Retrieves information about your own team

### EXAMPLE 2
```
Get-FplTeam -TeamId 12345
```

Retrieves information about the team with the ID 12345

## PARAMETERS

### -TeamId
A team ID to retrieve information about

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

[https://psfpl.readthedocs.io/en/master/functions/Get-FplTeam](https://psfpl.readthedocs.io/en/master/functions/Get-FplTeam)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeam.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Get-FplTeam.ps1)

