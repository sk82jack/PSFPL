# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0] - 2019-04-08
### Added
- Invoke-FplTransfer - a function to transfer players in and out of your team and activate your wildcard/free hit
- Added support for PowerShell Core
- Get-FplLineup - a function to retreive the users lineup for the upcoming gameweek
- Set-FplLineup - a function to make changes to the users lineup for the upcoming gameweek

### Changed
- The Name parameter for Get-FplPlayer now supports wildcard searches. Before it would do a partial search by default with no way to turn partial searching off so searching for players like Son was an issue. The new behaviour is that the whole name must match unless wildcards are specified.
- Improve performance by caching a users team ID

### Deprecated
- The WebName parameter on FplPlayer objects has been deprecated. Going forward the parameter will be Name instead. WebName still exists for backwards compatibility but it is considered legacy

### Removed
- The Id parameter on FplGameweek objects has been removed. Going forward the parameter will be Gameweek or GameweekId instead.

## [1.0.3] - 2019-02-09

## [1.0.2] - 2019-02-07
### Fixed
- Fixed a bug with rearranged fixtures that hadn't been rescheduled yet
- Fixed error handling for non-existent leagues

## [1.0.1] - 2019-02-05
### Fixed
- Fixed the online documentation links within the functions to valid URLs

## [1.0.0] - 2019-02-05
### Added
- Get-FplTeamPlayer - a function to get the player scoring information of a given team on a given gameweek
- Get-FplLeague - a function to retreive the list of leagues a given team is in
- Get-FplTeam - a function to retreive team data about a managers team
- Get-FplLeagueTable - a function to retreive the league table of a given league
- Get-FplFixture - a function to retreive fixture data
- Get-FplGameweek - a function to retreive gameweek data
- Get-FplPlayer - a function to retrieve player data
- Connect-FPL - a function to log into the FPL API to retrieve data about your team

[2.0]: https://github.com/sk82jack/PSFPL/compare/v1.0.3..v2.0
[1.0.3]: https://github.com/sk82jack/PSFPL/compare/v1.0.2..v1.0.3
[1.0.2]: https://github.com/sk82jack/PSFPL/compare/v1.0.1..v1.0.2
[1.0.1]: https://github.com/sk82jack/PSFPL/compare/v1.0.0..v1.0.1
[1.0.0]: https://github.com/sk82jack/PSFPL/tree/v1.0.0