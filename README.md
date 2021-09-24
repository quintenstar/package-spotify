# Spotify info-beamer package

[![Import](https://cdn.infobeamer.com/s/img/import.png)](https://info-beamer.com/use?url=http://github.com/quintenstar/package-spotify.git)

## Installation

Create a [Spotify developer account and a new app](https://developer.spotify.com/dashboard). Get both the Client ID and Client Secret for the next step.

Create a .env file in the project root folder and fill in the Client ID, Client Secret and [market](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

Run in root project folder and login for each of your Spotify accounts to generate a refresh token.

```console
python -m flask run
```

On the info-beamer website,

- [Add the Spotify package to info-beamer.](https://info-beamer.com/use?url=http://github.com/quintenstar/package-spotify.git)
- Add it as a plugin to the [Scheduled Player](https://info-beamer.com/package/7583l) package.

https://info-beamer.com/package/7583

- Fill in the Client ID, Client secret under authentication in the plugin settings.
- Add an account, give it a name and set the market and refresh token.
- On a Scheduled Player page add the Spotify Plugin and give it the same name (under the tile options).

## Settings

## Changelog

### Version 0.1.0

- Initial release
