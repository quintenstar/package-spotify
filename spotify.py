#!/usr/bin/python2.7
import hashlib
import os
import sys
import time
import traceback

import requests
from PIL import Image
from requests.auth import HTTPBasicAuth

from colorthief import ColorThief

try:
    from hosted import config, node
except ImportError:

    class node(object):
        @staticmethod
        def write_json(file, text):
            print(json.dumps(text, indent=4))


TOKEN_URL = "https://accounts.spotify.com/api/token"
PLAYBACK_STATE_ENDPOINT = "https://api.spotify.com/v1/me/player"
IMAGE_SIZES = [640, 300, 64]


def _convert(data):
    converted = data

    try:
        for i, image_size in enumerate(IMAGE_SIZES):
            images = data["item"]["album"]["images"]
            cover_image = images[i]["url"]

            converted["cover_image_{}".format(image_size)] = _cache_image(cover_image)
        # Use smallest image to get average color
        print(min(IMAGE_SIZES))
        converted["cover_image_color"] = _artwork_color(
            converted["cover_image_{}".format(min(IMAGE_SIZES))]
        )
    except:
        pass

    return converted


def _cache_image(url, ext="jpg"):
    cache_name = "cache-image-%s.%s" % (_md5(url), ext)
    print("caching %s" % url)
    if not os.path.exists(cache_name):
        try:
            with open(cache_name, "wb") as f:
                f.write(requests.get(url, timeout=20).content)
        except:
            traceback.print_exc()
            return
    return cache_name


def _md5(text):
    return hashlib.md5(text.encode("utf-8")).hexdigest()


def _artwork_color(file):
    # Get artwork color to use as background color
    print(file)
    try:
        image = ColorThief(file)
        artwork_color = image.get_color(quality=1)
        return artwork_color
    except:
        return (0, 0, 0)  # black


def cleanup(max_age=15 * 60):
    now = time.time()
    for filename in os.listdir("."):
        if not filename.startswith("cache-"):
            continue
        age = now - os.path.getctime(filename)
        if age > max_age:
            try:
                os.unlink(filename)
            except:
                traceback.print_exc()


def refresh_access_token(client_id, client_secret, refresh_token):
    response = requests.post(
        TOKEN_URL,
        auth=HTTPBasicAuth(client_id, client_secret),
        data={"grant_type": "refresh_token", "refresh_token": refresh_token},
    )
    response.raise_for_status()

    return response.json()["access_token"]


def _playback_state(access_token, market):
    return requests.get(
        PLAYBACK_STATE_ENDPOINT,
        headers={"Authorization": "Bearer " + access_token},
        params={"market": market},
    )


def spotify_data(access_token, market):
    response = _playback_state(access_token, market)
    response.raise_for_status()

    return _convert(response.json())


if __name__ == "__main__":
    import json

    from dotenv import dotenv_values, set_key

    env_config = dotenv_values(".env")

    SPOTIFY_CLIENT_ID = env_config["SPOTIFY_CLIENT_ID"]
    SPOTIFY_CLIENT_SECRET = env_config["SPOTIFY_CLIENT_SECRET"]

    SPOTIFY_REFRESH_TOKEN = env_config["SPOTIFY_REFRESH_TOKEN"]
    MARKET = env_config["MARKET"]

    SPOTIFY_ACCESS_TOKEN = refresh_access_token(
        SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_REFRESH_TOKEN
    )
    set_key(".env", "SPOTIFY_ACCESS_TOKEN", SPOTIFY_ACCESS_TOKEN)

    cleanup()
    data = spotify_data(SPOTIFY_ACCESS_TOKEN, MARKET)

    with open("spotify_playback_state.json.test", "w") as fp:
        json.dump(data, fp, indent=2)
