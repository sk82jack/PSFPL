# Connect-Fpl

## SYNOPSIS
Connect to the FPL API using provided login credentials

## SYNTAX

```
Connect-Fpl [-Credential] <PSCredential> [-Force] [<CommonParameters>]
```

## DESCRIPTION
Connect to the FPL API using provided login credentials
This is required for some functions which pull data related to your account

## EXAMPLES

### EXAMPLE 1
```
Connect-FPL -Credential myname@email.com
```

### EXAMPLE 2
```
Connect-FPL -Credential myname@email.com -Force
```

## PARAMETERS

### -Credential
Your FPL credentials that you use to log into https://fantasy.premierleague.com

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Create a connection regardless of whether there is already an existing connection

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://psfpl.readthedocs.io/en/master/functions/Connect-Fpl](https://psfpl.readthedocs.io/en/master/functions/Connect-Fpl)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Connect-FPL.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Connect-FPL.ps1)

