#!/bin/sh
# focus.sh feeds a waybar custom module with the seat-focused window title.
#
# Streams `oxctl subscribe focus`: follows the seat across outputs, so a
# single bar can show the title of wherever the seat is. See README.md
# for the single-bar module snippet.

while :; do
	oxctl subscribe focus |
		jq -c --unbuffered '{text: (.title // "")}'
	sleep 1 # reconnect loop: oxctl exits when the wm goes away
done
