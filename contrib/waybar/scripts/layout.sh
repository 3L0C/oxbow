#!/bin/sh
# layout.sh [OUTPUT]
#
# layout.sh feeds the waybar custom/layout module.
#
# Streams `oxctl subscribe layout` (for OUTPUT when given) and emits the
# current layout's symbol, with the layout name as tooltip.

output=${1-}
set --
if [ -n "$output" ]; then
	set -- --output "$output"
fi

while :; do
	oxctl subscribe layout "$@" |
		jq -c --unbuffered '
            { text: .symbol
            , tooltip: (if .scheme
                        then "\(.layout) \(.scheme)"
                        else .layout end)
            }'
	sleep 1 # reconnect loop: oxctl exits when the wm goes away
done
