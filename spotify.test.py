import spotify


class Test_Spotify_Artwork_color:
    def test_artwork_color_1(self):
        spotify.artwork_color("libclang.dll")

    def test_artwork_color_2(self):
        spotify.artwork_color(":")

    def test_artwork_color_3(self):
        spotify.artwork_color("/results.html")

    def test_artwork_color_4(self):
        spotify.artwork_color("program.exe")

    def test_artwork_color_5(self):
        spotify.artwork_color("navix376.py")

    def test_artwork_color_6(self):
        spotify.artwork_color("")

