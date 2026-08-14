# Waybar

oxbow ships waybar modules in
[`contrib/waybar`](https://github.com/3L0C/oxbow/tree/master/contrib/waybar).
The modules show the tags, the layout, the keymap mode, and
the window title. Each module is a standard waybar custom
module. A small shell script feeds each module from `oxctl
subscribe`. The bar is styled after dwm's native bar.

## Dependencies

- `waybar`
- `jq`
- `oxctl` on `$PATH`

## Quick start

Clone the repository, then run the installer while oxbow is
running:

```{prompt} bash
git clone https://github.com/3L0C/oxbow.git
cd oxbow/contrib/waybar
./install.sh
```

The installer finds your outputs with `oxctl output list`,
makes one bar for each output, and writes `config.jsonc`,
`style.css`, and `scripts/` to `~/.config/waybar`.

The installer does not overwrite existing files. Running it
with `--force` will backup the files and install the oxbow
bar.

Options:

| Flag            | Effect                                                         |
|-----------------|----------------------------------------------------------------|
| `--output NAME` | Install a bar for this output.                                 |
| `--tags LIST`   | Show only these tags. Comma-separated numbers between 1 and 9. |
| `--show-empty`  | Show tags that have no windows in a dim color.                 |
| `--force`       | Backup and replace existing files.                             |

To add the modules to a waybar configuration that you
already have, copy the module blocks from
`contrib/waybar/config.jsonc` and the `scripts/` directory.

## Modules

| Module          | Shows & Click Behavior                                                                                                                                        |
|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `custom/tag#N`  | Tag N. Hidden when the tag has no windows.<br>**Left**: view the tag.<br>**Right**: toggle the tag.<br>**Scroll**: view the next (down) or previous (up) tag. |
| `custom/layout` | The layout symbol.<br>**Left**: next layout.<br>**Right**: previous layout.<br>**Scroll**: next or previous tiling scheme.                                    |
| `custom/mode`   | The keymap mode. Hidden in the `normal` mode.<br>No click action.                                                                                             |
| `custom/window` | The title of the focused window on this output.<br>**Left**: open the overview.<br>**Right**: zoom.<br>**Scroll**: focus the next or previous window.         |

The tag state comes as CSS classes on `#custom-tag`:

| Tag        | Meaning                                        |
|------------|------------------------------------------------|
| `viewed`   | The tag is part of the selected (viewed) tags. |
| `occupied` | The tag contains one or more windows.          |
| `urgent`   | The tag contains one or more urgent windows.   |
| `focused`  | The tag contains the focused window.           |

```{note}
The `river/tags` module for `river-classic` used the
`focused` class the same way oxbow uses the `viewed` class.
```

## Optional: capture indicator

`scripts/capture.sh` feeds a screen-capture indicator. It
shows `REC` while a capture session records the output. The
installer copies the script but does not add the module. To
use it, add this block to your configuration and put
`custom/capture` in a module list:

```json
"custom/capture": {
    "exec": "~/.config/waybar/scripts/capture.sh OUTPUT_NAME",
    "return-type": "json",
    "format": "{}"
}
```

Style the active state with the `recording` CSS class on
`#custom-capture`.

## One bar: follow the seat

Each `custom/window` module is attached to one output. For
a single bar, use `focus.sh` in place of `window.sh`. It
subscribes to the `focus` events, so the title follows the
seat across outputs.

## Reconnect behavior

Each script runs `oxctl subscribe` in a retry loop. When
oxbow stops, the modules show no new data. Each script
enters a retry loop until oxbow returns, waiting one second
between attempts. A waybar restart is not necessary.

## Limitations

Each module is driven by a script. The default configuration
has 9 tag modules, one layout module, and one window module.
Eleven processes per bar, per output. The higher resource
usage enables precise interaction through per module click
actions.
