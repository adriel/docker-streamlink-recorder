#!/usr/bin/env bash

# Check if API returned message then log if message
# check_api "twitch api json" "json filter"
function check_api {
  channel_info="$1"
  filter="$2"
  if jq -e . >/dev/null 2>&1 <<<"$channel_info"; then # check input is valid json
    api_message=$(echo "$channel_info" | jq --raw-output "$filter" 2>&1)
    if [[ "$api_message" && "$api_message" != "null" ]]; then
      echo "Twitch API message: $api_message"
      echo "channel_info: $channel_info"
    fi
  else
    if [[ "$channel_info" =~ "Client.Timeout" ]]; then
      echo "Timeout - couldn't connect to twitch.com - filter: $filter"
    else
      echo "Input isn't json."
      echo "channel_info: $channel_info"
      echo "filter: $filter"
    fi
  fi
}

echo "Saving config file."
twitch configure --client-id "$clientID" --client-secret "$clientSecret"

echo "Waiting for stream to go live."
while [[ true ]]; do

  channel_info=$(twitch api get /streams -q "user_login=${streamName}" 2>&1)

  check_api "$channel_info" ".message"

  # Check if token needs refreshing
  if [[ "$channel_info" =~ "twitch token" || "$channel_info" =~  "Invalid OAuth token" ]]; then
    echo "Token missing, refreshing it.";
    twitch token
    # Try again, now that we have the token, it should work.
    channel_info=$(twitch api get /streams -q "user_login=${streamName}" 2>&1)
    echo "Token refreshed, now waiting for stream to go live."
  fi

  check_api "$channel_info" ".data[0].type"

  channel_live=$(echo "$channel_info" | jq --raw-output '.data[0].type')
  if [[ "$channel_live" == "live" ]]; then
    echo "$streamName stream is: $channel_live"

    date_unix=$(date +'%s')
    user_name=$(      echo "$channel_info" | jq --raw-output '.data[0].user_name')
    user_id=$(        echo "$channel_info" | jq --raw-output '.data[0].user_id')
    started_at=$(     echo "$channel_info" | jq --raw-output '.data[0].started_at')
    started_at_safe=$(echo "$started_at"   | sed -e 's/[^A-Za-z0-9._-]/./g') # safe name for filesystems
    game_name=$(      echo "$channel_info" | jq --raw-output '.data[0].game_name')
    stream_title=$(   echo "$channel_info" | jq --raw-output '.data[0].title')
    viewer_count=$(   echo "$channel_info" | jq --raw-output '.data[0].viewer_count')

    echo "user_name: $user_name"
    echo "user_id: $user_id"
    echo "started_at: $started_at"
    echo "started_at_safe: $started_at_safe"
    echo "game_name: $game_name"
    echo "stream_title: $stream_title"
    echo "viewer_count: $viewer_count"

    streamlink "$streamLink" "$streamQuality" "$streamOptions" --stdout | \
      ffmpeg \
      	-hide_banner \
        -loglevel error \
      	-i pipe: \
        -metadata title="$stream_title" \
        -metadata album_artist="$user_name" \
        -metadata show="$game_name" \
        -c copy -movflags faststart "/home/download/${game_name}/${user_name} ${date_unix} ${started_at_safe} ${stream_title} [viewers $viewer_count] (live_dl).mp4"
  fi
	sleep 60s
done
