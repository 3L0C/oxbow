#!/bin/sh
# window.sh [OUTPUT]
#
# window.sh feeds the waybar custom/window module.
#
# Streams `oxctl subscribe window` (for OUTPUT when given) and emits the focused
# window's title. The title is empty when the output has no focused window or
# when the seat is on a different output. The module gets
# the `focused` class while a seat is on this output, so CSS can recolor the
# focused output's title.

output=${1-}
set --
if [ -n "$output" ]; then
	set -- --output "$output"
fi

while :; do
	oxctl subscribe window "$@" |
		jq -c --unbuffered \
			'{text: (if .focused then (.title // "") else "" end), class: (if .focused then "focused" else "" end)}'
	sleep 1 # reconnect loop: oxctl exits when the wm goes away
done
