
import os
import sys
import time
import json
import requests
from typing import Any, List

class Musixmatch():
    """
    Musixmatch API client to fetch synchronized lyrics.

    Based on the syncedlyrics project by @moehmeni.

    GitHub Repository: https://github.com/moehmeni/syncedlyrics
    """

    ROOT_URL = "https://apic-desktop.musixmatch.com/ws/1.1/"

    def __init__(self) -> None:
        super().__init__()
        self.token: str = None

    def _get(self, operation: str, params: List[tuple]) -> requests.Response:
        """
        Make a GET request to the Musixmatch API.

        Parameters:
        - operation [str]: The API endpoint to call.
        - params [List[tuple]]: List of query parameters.

        Returns:
        - [requests.Response]: The response object.
        """

        # Get token if not already available
        if operation != "token.get" and self.token is None:
            self._get_token()
        # Add common parameters
        params.append(("app_id", "web-desktop-app-v1.0"))
        # Add user token if available
        if self.token is not None:
            params.append(("usertoken", self.token))
        # Add timestamp
        t = str(int(time.time() * 1000))
        params.append(("t", t))
        # Construct URL based on operation
        url = self.ROOT_URL + operation

        # Make the request
        response = requests.get(url, params=params)

        return response


    def _get_token(self) -> Any | None:
        """
        Get a new token from the Musixmatch API.

        Returns:
        - [Any | None]: The token if successful, None otherwise.
        """

        # Check if token is cached and not expired
        token_path = os.path.join(".syncedlyrics", "musixmatch_token.json")
        current_time = int(time.time())
        # Fetch cached token data
        if os.path.exists(token_path):
            with open(token_path, "r") as token_file:
                cached_token_data: json = json.load(token_file)
            cached_token: str = cached_token_data.get("token")
            expiration_time: str = cached_token_data.get("expiration_time")
            # If token is cached and not expired, don't fetch a new token
            if cached_token and expiration_time and current_time < expiration_time:
                self.token: str = cached_token
                return

        # Token not cached or expired, fetch a new token
        data: dict[str: str] = self._get("token.get", [("user_language", "en")]).json()
        # If token request fails, try again after 10 seconds
        if data["message"]["header"]["status_code"] == 401:
            time.sleep(10)
            return self._get_token()

        # Extract the new token and expiration time
        new_token = data["message"]["body"]["user_token"]
        expiration_time = current_time + 600  # 10 minutes expiration
        # Cache the new token
        self.token = new_token
        token_data = {"token": new_token, "expiration_time": expiration_time}
        os.makedirs(".syncedlyrics", exist_ok=True)
        with open(token_path, "w") as token_file:
            json.dump(token_data, token_file)


    def get_lrc_by_id(self, track_id: str) -> str:
        """
        Get the synchronized lyrics for a track by its ID.

        Parameters:
        - track_id [str]: The Musixmatch track ID.

        Returns:
        - [str]: The synchronized lyrics in LRC format.
        """

        response = self._get(
            "track.subtitle.get",
            [("track_id", track_id), ("subtitle_format", "lrc")],
        )
        # If request fails, return None
        if not response.ok:
            return None
        # Extract the lyrics from the response, return None if not found
        body = response.json()["message"]["body"]
        if not body:
            return None
        # Extract the lyrics string
        lrc_str = body["subtitle"]["subtitle_body"]
        return lrc_str


if __name__ == "__main__":
    track_id = sys.argv[1]
    musixmatch = Musixmatch()
    synced_lyrics = musixmatch.get_lrc_by_id(track_id)
    print(synced_lyrics)
