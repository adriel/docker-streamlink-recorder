# docker-streamlink-recorder
Automated Dockerfile to record livestreams with streamlink and twitch API (requried)

## Description
This is a Docker Container to record a livestream. It uses the official [Python Image](https://hub.docker.com/_/python) with the Tag *buster*  , installs [streamlink](https://github.com/streamlink/streamlink) and uses the Script [streamlink-recorder.sh](https://raw.githubusercontent.com/lauwarm/docker-streamlink-recorder/python3.8.1_buster_1.3.1/streamlink-recorder.sh) to periodically check if the stream is live.

## Usage
To run the Container:
```bash
docker run -v /path/to/vod/folder/:/home/download -e stream_link='' -e stream_quality='' -e stream_name='' -e stream_options='' -e uid='' -e gid='' lauwarm/streamlink-recorder
```

Example:
```bash
docker run -v /home/:/home/download -e stream_link='twitch.tv/twitch' -e stream_quality='best' -e stream_name='twitch' -e stream_options='--twitch-disable-hosting' -e uid='1001' -e gid='1001' adriel/streamlink-autodl
```

docker-compose file:
```
version: "3.8"
services:
  twitch_lara6683:
    container_name: lara6683
    image: adriel/streamlink-autodl
    restart: unless-stopped
    volumes:
      - "/home:/home/download"
      - /etc/localtime:/etc/localtime:ro
    environment:
      TZ: Pacific/Auckland
      client_id: {your twitch client id}
      client_secret: {your twitch client secret}
      stream_link: twitch.tv/lara6683
      stream_name: lara6683
      stream_options: '--twitch-disable-ads --hls-live-restart --twitch-disable-hosting'
      stream_quality: best
      uid: 1000
      gid: 1000
```

## Notes

`/home/download` - the place where the vods will be saved. Mount it to a desired place with `-v` option.

`/home/script` - the place where the scripts are stored. (entrypoint.sh and streamlink-recorder.sh)

`/home/plugins` - the place where the streamlink plugins are stored.

`client_id` - the twitch api client id.

`client_secret` - the tiwtch api client secret.

`stream_link` - the url of the stream you want to record.

`stream_quality` - quality options (best, high, medium, low).

`stream_name` - name for the stream.

`stream_options` - streamlink flags (--twitch-disable-hosting, separated by space)

`uid` - USER ID, map to your desired User ID (fallback to 9001)

`gid` - GROUP ID, map to your desired Group ID (fallback to 9001)

The File will be saved as `streamName-YearMonthDay-HourMinuteSecond.mkv`
