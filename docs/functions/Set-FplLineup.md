# Set-FplLineup

## SYNOPSIS
Set your team lineup for the upcoming gameweek

## SYNTAX

```
Set-FplLineup [[-PlayersIn] <PSObject[]>] [[-PlayersOut] <PSObject[]>] [[-Captain] <Object>]
 [[-ViceCaptain] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Set your team lineup for the upcoming gameweek

## EXAMPLES

### EXAMPLE 1
```
Set-FplLineup -PlayersIn Son -PlayersOut Pogba
```

This will remove Pogba from the starting XI and swap him with Son

### EXAMPLE 2
```
Set-FplLineup -PlayersIn Son, Rashford, Alexander-Arnold -PlayersOut Ings, Diop, Digne
```

This will remove Ings, Diop and Digne from the starting XI and swap them with Son, Rashford and Alexander-Arnold

### EXAMPLE 3
```
Set-FplLineup -PlayersIn @{Name = 'Sterling'; Club = 'Man City'} -PlayersOut Mane
```

You can use a hashtable to identify players if you have two players with the same name in your team.

### EXAMPLE 4
```
Set-FplLineup -Captain Salah
```

This will set your captain for the upcoming gameweek to Salah

### EXAMPLE 5
```
Set-FplLineup -ViceCaptain Sterling
```

This will set your vice captain for the upcoming gameweek to Sterling

### EXAMPLE 6
```
Set-FplLinup -PlayersIn Sane -PlayersOut Diop -Captain Sane -ViceCaptain Pogba
```

This will swap out Diop for Sane in your starting XI and then set Sane to be the captain and Pogba to be the vice captain

## PARAMETERS

### -PlayersIn
The players which you wish to bring in to the starting XI.
Alternatively, if you are just swapping the order of players on your bench then use PlayersIn for one bench player and PlayersOut for the other
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
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlayersOut
The players you wish to remove from the starting XI.
Alternatively, if you are just swapping the order of players on your bench then use
PlayersIn for one bench player and PlayersOut for the other.
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
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Captain
The player who you wish to be Captain of your team

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

### -ViceCaptain
The player who you wish to be ViceCaptain of your team

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://psfpl.readthedocs.io/en/master/functions/Set-FplLineup](https://psfpl.readthedocs.io/en/master/functions/Set-FplLineup)

[https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Set-FplLineup.ps1](https://github.com/sk82jack/PSFPL/blob/master/PSFPL/Public/Set-FplLineup.ps1)

