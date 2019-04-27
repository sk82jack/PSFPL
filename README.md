# PSFPL

[![Build Status](https://dev.azure.com/sk82jack/PSFPL/_apis/build/status/sk82jack.PSFPL)](https://dev.azure.com/sk82jack/PSFPL/_build/latest?definitionId=4)
[![Documentation Status](https://readthedocs.org/projects/psfpl/badge/?version=master)](https://psfpl.readthedocs.io/en/master/?badge=master)

## Description

A PowerShell Module to connect to and interact with the FPL API at https://fantasy.premierleague.com/

Authored by Jack Denton

## Installing

The easiest way to get PSFPL is using the [PowerShell Gallery](https://powershellgallery.com/packages/PSFPL/)!

### Installing the module

You can install it using:

``` PowerShell
PS> Install-Module -Name PSFPL
```

### Updating PSFPL

Once installed from the PowerShell Gallery, you can update it using:

``` PowerShell
PS> Update-Module -Name PSFPL
```

### Uninstalling PSFPL

To uninstall PSFPL:

``` PowerShell
PS> Uninstall-Module -Name PSFPL
```

## Examples
For a full list of available commands please check the documentation at https://psfpl.readthedocs.io/en/master/

### Get-FplPlayer

This function will allow you to pull information on players. You can run the function as is to get information on all players in the game:

![Get-FplPlayer](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplPlayer.gif)

There are also parameters to allow you to filter your search based on name, club, position, price and dream team.

### Get-FplFixture

This function will allow you to pull information on fixtures. You can run the function as is to get information on all fixtures:

![Get-FplFixture](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplFixture.gif)

There are also parameters to allow you to filter your search based on gameweek and club.

### Get-FplGameweek

This function will allow you to pull information on gameweeks. You can run the function as is to get information on all gameweeks:

![Get-FplGameweek](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplGameweek.gif)

There are also parameters to allow you to filter your search based on the gameweek number and the current gameweek.

### Connect-Fpl

There are a few functions which require authentication in order to pull information about your own team. You can run this function to log in with your credentials:

![Connect-Fpl](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Connect-Fpl.gif)

If you want to change the logged in account then you can run the function again with the `Force` parameter.

### Get-FplLeague

This function will allow you to pull league information for a specific team. If you have authenticated with the API then it will show your own leagues:

![Get-FplLeague](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplLeague.gif)

If you haven't authenticated already and don't specify a team ID with the `TeamID` parameter then it will ask for your credentials to log in and pull your leagues.

### Get-FplLeagueTable

This function will allow you to pull your league tables. This can take a few minutes for large public leagues. The easiest way is to filter the results of `Get-FplLeague` and pipe it straight into this function:

![Get-FplLeagueTable](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplLeagueTable.gif)

There are `LeagueID` and `Type` parameters available to use if you don't want to pipe the league in from `Get-FplLeague`.

### Get-FplTeam

This function will allow you to pull team information for a specific team. If you have authenticated with the API then it will show your own team:

![Get-FplTeam](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplTeam.gif)

If you haven't authenticated already and don't specify a team ID with the `TeamID` parameter then it will ask for your credentials to log in and pull your leagues.

### Get-FplTeamPlayer

This function will allow you to pull the lineup for a specific team in a specified gameweek. If you have authenticated with the API then it will show your own lineup from the current gameweek:

![Get-FplTeamPlayer](https://raw.githubusercontent.com/sk82jack/PSFPL/master/docs/images/Get-FplTeamPlayer.gif)

If you haven't authenticated already and don't specify a team ID with the `TeamID` parameter then it will ask for your credentials to log in and pull your lineup.

## Contributing to PSFPL

Interested in contributing? Read how you can [Contribute](https://github.com/sk82jack/PSFPL/blob/master/Contributing.md) to PSFPL

## Release History

A detailed release history is contained in the [Change Log](https://github.com/sk82jack/PSFPL/blob/master/CHANGELOG.md).

## License

PSFPL is provided under the [MIT license](https://github.com/sk82jack/PSFPL/blob/master/LICENSE).

