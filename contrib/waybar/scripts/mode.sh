#!/bin/sh
# mode.sh feeds the waybar custom/mode module.
#
# Streams `oxctl subscribe mode` and emits the seat's keymap mode: empty
# text in "normal" so waybar hides the module, the mode name otherwise,
# always with the mode as CSS class for styling.

while :; do
	oxctl subscribe mode |
		jq -c --unbuffered \
			'{text: (if .mode == "normal" then "" else .mode end), class: .mode}'
	sleep 1 # reconnect loop: oxctl exits when the wm goes away
done
