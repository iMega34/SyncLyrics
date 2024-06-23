
import sys
import json
import requests
from typing import Callable
from bs4 import BeautifulSoup, Tag

def get_lyrics(song_url) -> str:
    """
    Fetch the lyrics of a song from a Musixmatch URL

    ### Parameters:
    - song_url: [str] URL of the song in Musixmatch

    ### Returns:
    - lyrics: [str] Lyrics of the song
    """

    # Headers to avoid scraping detection
    headers: dict[str, str] = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    response: requests.Response = requests.get(song_url, headers=headers)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')

        # Finder function to search the script tag containing the JSON with the lyrics
        tag_finder: Callable = lambda text: text and 'props' in text
        script_tag: Tag = soup.find('script', string=tag_finder)
        if script_tag:
            # Clean the JSON text and extract the lyrics
            json_text: str = script_tag.string.strip()
            json_data: dict[str, str] = json.loads(json_text)
            lyrics: str = json_data['props']['pageProps']['data']['trackInfo']['data']['lyrics']['body']
            return lyrics
        else:
            return "Lyrics not found in the page"
    else:
        return f"Error loading the page: {response.status_code}"


if __name__ == "__main__":
    song_url = sys.argv[1]
    lyrics = get_lyrics(song_url)
    print(lyrics)
