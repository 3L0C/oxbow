#!/bin/sh
# install.sh install the oxbow waybar bar to ~/.config/waybar.
#
# Actions performed:
# - Creates config.jsonc once per output (an array of bar blocks)
# - Copies style.css and the scripts, and refuses to overwrite anything already there
# - Use --force to back up existing files and install the generated files as the default
#
# Requirements:
# - jq
# - active oxbow session (optional: for auto-detecting outputs)

set -eu

usage() {
    cat >&2 <<'EOF'
usage: install.sh [--output NAME]... [--tags LIST] [--show-empty] [--force]

Install the oxbow waybar bar to $XDG_CONFIG_HOME/waybar (~/.config/waybar).

  --output NAME   target output (repeatable); default: auto-detect from the
                  running oxbow via `oxctl output list`
  --tags LIST     comma-separated tag numbers to show, subset of 1-9
                  (default: 1,2,3,4,5,6,7,8,9)
  --show-empty    render vacant tags dimmed instead of hiding them
  --force         overwrite existing files, backing each up to
                  FILE.bak.TIMESTAMP first
  -h, --help      show this help
EOF
    exit "${1-1}"
}

die() {
    echo "install.sh: $1" >&2
    exit 1
}

outputs=''
tags='1,2,3,4,5,6,7,8,9'
show_empty=false
force=false

while [ $# -gt 0 ]; do
    case $1 in
    --output)
        [ $# -ge 2 ] || die "--output needs a value"
        outputs="$outputs$2
"
        shift 2
        ;;
    --tags)
        [ $# -ge 2 ] || die "--tags needs a value"
        tags=$2
        shift 2
        ;;
    --show-empty)
        show_empty=true
        shift
        ;;
    --force)
        force=true
        shift
        ;;
    -h | --help) usage 0 ;;
    *) usage ;;
    esac
done

command -v jq >/dev/null || die "jq is required"

tags_json='['
for t in $(printf '%s' "$tags" | tr ',' ' '); do
    case $t in
    [1-9]) tags_json="$tags_json$t," ;;
    *) die "--tags takes a comma-separated subset of 1-9 (got '$t')" ;;
    esac
done
[ "$tags_json" != '[' ] || die "--tags is empty"
tags_json="${tags_json%,}]"

if [ -z "$outputs" ]; then
    command -v oxctl >/dev/null ||
        die "oxctl not found; pass --output NAME to skip auto-detection"
    outputs=$(oxctl output list 2>/dev/null | jq -r '.[]') ||
        die "could not auto-detect outputs (is oxbow running?); pass --output NAME"
    [ -n "$outputs" ] ||
        die "oxbow reports no outputs; pass --output NAME"
fi
outputs_json=$(printf '%s\n' "$outputs" | jq -Rn '[inputs | select(length > 0)]')

src=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
dest="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
scripts='tag.sh window.sh layout.sh mode.sh focus.sh'

config=$(
    grep -v '^[[:space:]]*//' "$src/config.jsonc" |
        jq --argjson outputs "$outputs_json" \
            --argjson tags "$tags_json" \
            --argjson show "$show_empty" '
      . as $template
      | [ $outputs[] as $out
          | $template
          | walk(if type == "string" then gsub("OUTPUT_NAME"; $out) else . end)
          | with_entries(select(
              (.key | startswith("custom/tag#") | not)
              or ((.key | ltrimstr("custom/tag#") | tonumber) as $n
                  | $tags | index($n))))
          | .["modules-left"] |= map(select(
              (startswith("custom/tag#") | not)
              or ((ltrimstr("custom/tag#") | tonumber) as $n
                  | $tags | index($n))))
          | if $show
            then reduce (keys[] | select(startswith("custom/tag#"))) as $k
                   (.; .[$k].exec += " --show-empty")
            else . end
        ]'
) || die "transforming config.jsonc failed"

targets="$dest/config $dest/config.jsonc $dest/style.css"
for s in $scripts; do
    targets="$targets $dest/scripts/$s"
done

existing=''
for f in $targets; do
    [ -e "$f" ] && existing="$existing  $f
"
done
if [ -n "$existing" ]; then
    if [ "$force" = true ]; then
        stamp=$(date +%Y%m%d%H%M%S)
        printf '%s' "$existing" | while read -r f; do
            mv "$f" "$f.bak.$stamp"
            echo "backed up $f -> $f.bak.$stamp"
        done
    else
        echo "install.sh: refusing to overwrite existing files:" >&2
        printf '%s' "$existing" >&2
        echo "re-run with --force to back them up and overwrite" >&2
        exit 1
    fi
fi

mkdir -p "$dest/scripts"
printf '%s\n' "$config" >"$dest/config.jsonc"
cp "$src/style.css" "$dest/style.css"
for s in $scripts; do
    cp "$src/scripts/$s" "$dest/scripts/$s"
    chmod 755 "$dest/scripts/$s"
done

echo "installed to $dest:"
echo "  config.jsonc  ($(printf '%s\n' "$outputs" | grep -c .) bar(s): $(printf '%s' "$outputs" | tr '\n' ' '))"
echo "  style.css"
echo "  scripts/      ($scripts)"
echo "run 'waybar' to start; re-run with --force to update"
