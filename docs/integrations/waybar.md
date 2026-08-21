# Waybar

oxbow provides a waybar template in
[`contrib/waybar`](https://github.com/3L0C/oxbow/tree/master/contrib/waybar).
The bar is styled after dwm's native bar.

## Dependencies

- `waybar`
- `jq`
- `oxctl` on `$PATH`

## Quick start

Clone the repository, then run the installer while inside
oxbow:

```{prompt} bash
git clone https://github.com/3L0C/oxbow.git
cd oxbow/contrib/waybar
./install.sh
```

Options:

| Flag            | Effect                                                         |
|-----------------|----------------------------------------------------------------|
| `--output NAME` | Install a bar for this output.                                 |
| `--tags LIST`   | Show only these tags. Comma-separated numbers between 1 and 9. |
| `--show-empty`  | Show tags that have no windows in a dim color.                 |
| `--force`       | Backup and replace existing files.                             |

```{note}
The install script finds your outputs with `oxctl output
list`, makes one bar for each output, and writes
`config.jsonc`, `style.css`, and `scripts/` to
`~/.config/waybar`.

It does not overwrite existing files. Running it with
`--force` will backup the files before installation.
```

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
install script copies `capture.sh` but does not add the
module. To use it, add this block to your configuration:

```json
"custom/capture": {
    "exec": "~/.config/waybar/scripts/capture.sh OUTPUT_NAME",
    "return-type": "json",
    "format": "{}"
}
```

Then, add `custom/capture` to a module list:

```{code-block} json
:emphasize-lines: 2
"modules-right": [
    "custom/capture",
    "clock"
],
```


Style the active state with the `recording` CSS class on
`#custom-capture`.
