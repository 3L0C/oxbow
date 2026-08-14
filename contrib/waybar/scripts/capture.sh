#!/bin/sh
# capture.sh [OUTPUT]
#
# capture.sh feeds the waybar custom/capture module.
#
# Streams `oxctl subscribe output` (for OUTPUT when given) and emits "REC"
# with the `recording` class while the output has a capture session, empty
# text otherwise.

output=${1-}
set --
if [ -n "$output" ]; then
	set -- --output "$output"
fi

while :; do
	oxctl subscribe output "$@" |
		jq -c --unbuffered \
			'{text: (if .captured then "REC" else "" end)
            , class: (if .captured then "recording" else "" end)}'
	sleep 1 # reconnect loop: oxctl exits when the wm goes away
done
