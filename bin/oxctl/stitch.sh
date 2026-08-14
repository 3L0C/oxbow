#!/bin/sh
# Stitch one man page from the cmdliner help of each oxctl command.
#
# Usage: stitch.sh OXCTL_EXE > oxctl.1
#
# The page starts with the top-level help. Then one .SH section follows for each
# command path, in the order that `cmdliner tool-commands` gives. The tail
# sections of the top-level help (COMMON OPTIONS, EXIT STATUS) move to the end
# of the page. The `bind PATH` commands are not included; each one mirrors a
# top-level command. The `bind` group page itself stays.

set -eu

oxctl="$1"

tail_re='^[.]SH "?(COMMON OPTIONS|EXIT STATUS|ENVIRONMENT|SEE ALSO)'

"$oxctl" --help=groff | awk -v re="$tail_re" '$0 ~ re { exit } { print }'

# One .SH section per command. For each command page: drop the preamble, the
# NAME heading, and the tail sections; demote the other .SH headings to .SS;
# keep the NAME description as the first paragraph of the section.
cmdliner tool-commands "$oxctl" | grep -v '^bind ' | while IFS= read -r path; do
    printf '.SH "%s"\n' "$(printf '%s' "$path" | tr '[:lower:]' '[:upper:]')"
    # shellcheck disable=SC2086
    "$oxctl" $path --help=groff | awk -v re="$tail_re" '
        BEGIN { skip = 1 }
        /^\.SH / {
            skip = 0
            if ($0 ~ re) { drop = 1; next }
            if ($0 ~ /^\.SH "?NAME/) { drop = 2; next }
            drop = 0
            sub(/^\.SH /, ".SS ")
        }
        drop == 2 && / \\- / { sub(/^.* \\- /, ""); print ".P"; print; next }
        skip || drop { next }
        { print }
    '
done

"$oxctl" --help=groff | awk -v re="$tail_re" '$0 ~ re { on = 1 } on { print }'
