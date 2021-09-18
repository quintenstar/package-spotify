#!/usr/bin/python2.7

import requests
from flask import Flask, request, redirect

try:  # Python 3+
    from urllib.parse import quote
except ImportError:  # Python 2.x
    from urllib import quote

from dotenv import dotenv_values, set_key

env_config = dotenv_values(".env")

AUTHORIZE_URL = "https://accounts.spotify.com/authorize"
TOKEN_URL = "https://accounts.spotify.com/api/token"

SPOTIFY_REDIRECT_URL = env_config["SPOTIFY_REDIRECT_URL"]
SPOTIFY_CLIENT_ID = env_config["SPOTIFY_CLIENT_ID"]
SPOTIFY_CLIENT_SECRET = env_config["SPOTIFY_CLIENT_SECRET"]

scopes = ["user-read-playback-state", "user-read-currently-playing"]

app = Flask(__name__)


def authorization_url(scopes, show_dialog=True):
    return "{}?client_id={}&response_type=code&redirect_uri={}&scope={}&show_dialog={}".format(
        AUTHORIZE_URL,
        SPOTIFY_CLIENT_ID,
        SPOTIFY_REDIRECT_URL,
        quote(" ".join(scopes)),
        show_dialog,
    )


def request_token(code):
    return requests.post(
        TOKEN_URL,
        data={
            "client_id": SPOTIFY_CLIENT_ID,
            "client_secret": SPOTIFY_CLIENT_SECRET,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": SPOTIFY_REDIRECT_URL,
        },
    )


@app.route("/callback")
def callback():
    code = request.args.get("code")
    set_key(".env", "SPOTIFY_AUTHORIZATION_CODE", code)

    access_token = request_token(code).json()

    SPOTIFY_ACCESS_TOKEN = access_token["access_token"]
    SPOTIFY_REFRESH_TOKEN = access_token["refresh_token"]
    SPOTIFY_EXPIRES_IN = access_token["expires_in"]

    set_key(".env", "SPOTIFY_ACCESS_TOKEN", SPOTIFY_ACCESS_TOKEN)
    set_key(".env", "SPOTIFY_REFRESH_TOKEN", SPOTIFY_REFRESH_TOKEN)
    # set_key(".env", "SPOTIFY_EXPIRES_IN", SPOTIFY_EXPIRES_IN)

    return "<h1>Success!</h1>\n\
        SPOTIFY_CLIENT_ID: \t {}\n\
        SPOTIFY_CLIENT_SECRET: \t {}\n\
        SPOTIFY_REFRESH_TOKEN: \t {}\n\
        SPOTIFY_EXPIRES_IN: \t {}\n\
        Flask now can be closed\n".format(
        SPOTIFY_CLIENT_ID,
        SPOTIFY_CLIENT_SECRET,
        SPOTIFY_REFRESH_TOKEN,
        SPOTIFY_EXPIRES_IN,
    ).replace(
        "\n", "<br/>"
    )


@app.route("/")
def login():
    return redirect(authorization_url(scopes))


if __name__ == "__main__":
    app.run()
