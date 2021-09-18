#!/usr/bin/python2.7

import requests
from requests.auth import HTTPBasicAuth


try:
    from hosted import node
except ImportError:

    class node(object):
        @staticmethod
        def write_json(file, text):
            print(json.dumps(text, indent=4))


TOKEN_URL = "https://accounts.spotify.com/api/token"
PLAYBACK_STATE_ENDPOINT = "https://api.spotify.com/v1/me/player"


def save_playback_state(data):
    node.write_json("playback_state.json", data)


def playback_state(access_token, market):
    # TODO if request unsuccesfull
    return requests.get(
        PLAYBACK_STATE_ENDPOINT,
        headers={"Authorization": "Bearer " + access_token},
        params={"market": market},
    ).json()


def refresh_access_token(client_id, client_secret, refresh_token):
    # TODO if request unsuccesfull
    return requests.post(
        TOKEN_URL,
        auth=HTTPBasicAuth(client_id, client_secret),
        data={"grant_type": "refresh_token", "refresh_token": refresh_token},
    ).json()["access_token"]


if __name__ == "__main__":
    import json
    from dotenv import dotenv_values, set_key

    env_config = dotenv_values(".env")

    SPOTIFY_CLIENT_ID = env_config["SPOTIFY_CLIENT_ID"]
    SPOTIFY_CLIENT_SECRET = env_config["SPOTIFY_CLIENT_SECRET"]

    # CURRENTLY_PLAYING_ENDPOINT = (
    #     "https://api.spotify.com/v1/me/player/currently-playing"
    # )

    SPOTIFY_ACCESS_TOKEN = env_config["SPOTIFY_ACCESS_TOKEN"]
    SPOTIFY_REFRESH_TOKEN = env_config["SPOTIFY_REFRESH_TOKEN"]
    MARKET = "NL"

    # data = requests.get(
    #     CURRENTLY_PLAYING_ENDPOINT,
    #     headers={"Authorization": "Bearer " + SPOTIFY_ACCESS_TOKEN},
    #     params={"market": MARKET},
    # )
    # with open("spotify_current_track.json.test", "w") as fp:
    #     json.dump(data.json(), fp, indent=2)

    SPOTIFY_ACCESS_TOKEN = refresh_access_token(
        SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_REFRESH_TOKEN
    )

    set_key(".env", "SPOTIFY_ACCESS_TOKEN", SPOTIFY_ACCESS_TOKEN)

    data = playback_state(SPOTIFY_ACCESS_TOKEN, MARKET)

    with open("spotify_playback_state.json.test", "w") as fp:
        json.dump(data, fp, indent=2)
