# oxctl

oxbow exposes its configuration and state over IPC. `oxctl`
is the command-line interface for controlling oxbow. This
page follows the `oxctl` command tree.  Pass `--help` to any
command to see its options.

## bind

`oxctl bind COMMAND to KEYBIND` binds a key or pointer
button to any `oxctl` command. `--mode MODE` puts the bind
in a [keymap mode](#keymap) (default `normal`).

```{prompt} bash
oxctl bind window zoom to Super+space
oxctl bind spawn foot to Super+Return
oxctl bind window move drag to Super+Btn_left
```

```{attention}
Queries like `oxctl window list` cannot be bound as they are not commands.
```

A `KEYBIND` is a set of modifiers plus a keysym or a button,
joined with `+`.

| Part      | Values                                                                                                                                                                                                     |
|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Modifiers | `Shift`, `Control`, `Mod1`/`Alt`, `Mod3`, `Mod4`/`Super`/`Logo`, `Mod5`                                                                                                                                    |
| Keysym    | Any [xkbcommon keysym](https://raw.githubusercontent.com/xkbcommon/libxkbcommon/refs/heads/master/include/xkbcommon/xkbcommon-keysyms.h) without the `XKB_KEY_` prefix, e.g., `Return` vs `XKB_KEY_Return` |
| Button    | `Btn_left`, `Btn_right`, `Btn_middle`, `Btn_side`, `Btn_extra`, `Btn_forward`, `Btn_back`, `Btn_task`, `Btn_0` … `Btn_9`                                                                                   |

## border

`oxctl border width WIDTH` sets the border width in pixels.

`oxctl border color STATE COLOR` sets the border color for
one window state. Colors are `#RRGGBB` or `0xRRGGBBAA`.

| Command                               | State                                              |
|---------------------------------------|----------------------------------------------------|
| `oxctl border color focused COLOR`    | The focused window                                 |
| `oxctl border color urgent COLOR`     | A window with the urgent flag                      |
| `oxctl border color captured COLOR`   | A window recorded by a capture session (e.g., OBS) |
| `oxctl border color swallowing COLOR` | A window swallowing a terminal                     |
| `oxctl border color unfocused COLOR`  | All other windows                                  |

## config

`oxctl config reset` restores the stock settings on every
output and tag: layout parameters, gaps, borders, cursor
theme, spawn behavior, pointer behavior, and drag retile.

`oxctl config reset --all` also removes the window rules,
the input rules, the window and output labels, and every
keybind and keymap mode. The
[default](./defaults.md#keybinds) binds come back.

```{note}
Any input rules already applied are not reset.
```

## exec

`oxctl exec COMMAND...` runs `COMMAND` directly, with no
shell in between. Use [`spawn`](#spawn) when the command
needs shell syntax.

```{prompt} bash
oxctl exec -- /usr/bin/emacs --eval '(scratch-buffer)'
```

## gaps

Each command takes a signed delta (`+2`, `-2`) or an
absolute value (`8`), and accepts `--output NAME` or
`--all`.

| Command                     | Effect                                             |
|-----------------------------|----------------------------------------------------|
| `oxctl gaps inner DELTA`    | The gap between one or more windows                |
| `oxctl gaps outer DELTA`    | The gap between windows and the edges of an output |
| `oxctl gaps overview DELTA` | The gap in the [overview](#output-overview) grid   |

## input

### input cursor

`oxctl input cursor theme NAME SIZE` sets the XCursor theme.

### input keyboard

`oxctl input keyboard repeat RATE DELAY` sets the key repeat
rate (keys per second) and delay (ms). `oxctl input
keyboard layout-file PATH` loads an
[XKB keymap file](https://xkbcommon.org/doc/current/keymap-text-format-v1-v2.html).

### input list

`oxctl input list` prints the input devices. Filter with
`--name REGEX` and `--role ROLE` (`keyboard`, `mouse`,
`touchpad`, `touch`, or `tablet`). Accepts the following
flags:

| Flag              | Effect                                 |
|-------------------|----------------------------------------|
| `--fields FIELDS` | Show only these columns, in this order |
| `--expand`        | Do not truncate cell values            |
| `--json`          | Print the raw JSON reply               |

Long cell values truncate at 15 characters with `...`; use
`--expand` or `--fields` to see them in full.

### input pointer

`oxctl input pointer follow POLICY` sets how pointer motion
changes focus. `oxctl input pointer follow cycle` steps
through the policies.

| Policy          | Effect                                                            |
|-----------------|-------------------------------------------------------------------|
| `always`        | Focus follows the pointer                                         |
| `never`         | Focus changes only on click or command                            |
| `not-scrolling` | Follow, except when it would cause the scrolling layout to scroll |

`oxctl input pointer warp on|off|toggle` sets whether a
keyboard focus change warps the pointer to the window.
Focus commands override it per call with `--warp` and
`--no-warp`.

### input rules

An input rule configures devices by name pattern.

```{prompt} bash
oxctl input rules touchpad --name '.*' --tap enabled --natural-scroll enabled
oxctl input rules mouse --name Logitech --accel-profile flat
oxctl input rules list
oxctl input rules remove 0,2,3
```

`touchpad` and `mouse` add or update a rule. A rule needs
`--name REGEX` and at least one setting. The settings mirror
the [libinput configuration options](https://wayland.freedesktop.org/libinput/doc/latest/configuration.html).

Settings for both device types:

| Flag                        | Values                                                    |
|-----------------------------|-----------------------------------------------------------|
| `--accel-profile PROFILE`   | `none`, `flat`, `adaptive`, or `custom`                   |
| `--accel-speed SPEED`       | `-1.0` to `1.0`                                           |
| `--left-handed OPTION`      | Enable or disable the left-handed button layout           |
| `--middle-emulation OPTION` | Enable or disable middle-button emulation                 |
| `--natural-scroll OPTION`   | Enable or disable natural scrolling                       |
| `--scroll-factor FACTOR`    | Scroll speed multiplier                                   |
| `--scroll-method METHOD`    | `no-scroll`, `two-finger`, `edge`, or `on-button-down`    |
| `--send-events OPTION`      | `enabled`, `disabled`, or `disabled-on-external-mouse`    |

Touchpad only:

| Flag                                   | Values                                                |
|----------------------------------------|-------------------------------------------------------|
| `--click-method METHOD`                | `none`, `button-areas`, or `clickfinger`              |
| `--clickfinger-button-map BUTTON`      | `left-right-middle` or `left-middle-right`            |
| `--disable-while-trackpointing OPTION` | Enable or disable disable-while-trackpointing         |
| `--disable-while-typing OPTION`        | Enable or disable disable-while-typing                |
| `--drag OPTION`                        | Enable or disable tap-and-drag                        |
| `--drag-lock MODE`                     | `disabled`, `enabled-timeout`, or `enabled-sticky`    |
| `--tap OPTION`                         | Enable or disable tap-to-click                        |
| `--tap-button-map BUTTON`              | `left-right-middle` or `left-middle-right`            |
| `--three-finger-drag OPTION`           | `disabled`, `enabled-3fg`, or `enabled-4fg`           |

Mouse only:

| Flag                          | Values                                     |
|-------------------------------|--------------------------------------------|
| `--scroll-button BUTTON`      | The button that scrolls with `on-button-down` |
| `--scroll-button-lock OPTION` | Enable or disable the scroll-button lock   |

### input touchpad and input mouse

`oxctl input touchpad` and `oxctl input mouse` apply
settings to the matching devices one time, without a rule.

```{prompt} bash
oxctl input touchpad --name '.*' --tap enabled
oxctl input mouse --name Logitech.* --accel-profile flat
```

The commands take the same flags as
[input rules](#input-rules).

## keymap

A keymap mode is a named set of binds, like river's modes.

| Command                          | Effect                |
|----------------------------------|-----------------------|
| `oxctl keymap mode declare MODE` | Create a mode         |
| `oxctl keymap mode enter MODE`   | Switch to a mode      |
| `oxctl keymap list`              | List the active binds |

`oxctl bind --mode MODE ...` adds a bind to a mode.  `oxctl
keymap mode enter normal` returns to the default mode.
`oxctl keymap list --all` lists the binds of every seat.

## layout

oxbow has three layouts: `tiling`, `scrolling`, and
`floating`. Layout settings are per tag. Each command below
applies to the focused output. Add `--output NAME` to target
one output, or `--all` to apply the change everywhere and
set the default for new outputs.

| Command                  | Effect                              |
|--------------------------|-------------------------------------|
| `oxctl layout tiling`    | Switch to the tiling layout         |
| `oxctl layout scrolling` | Switch to the scrolling layout      |
| `oxctl layout floating`  | Switch to the floating layout       |
| `oxctl layout next`      | Cycle to the next layout            |
| `oxctl layout prev`      | Cycle to the previous layout        |
| `oxctl layout query`     | Print current and available layouts |

### Tiling

The tiling layout has a master area and a stack area.

#### Schemes

A scheme controls how the stack area arranges its windows.
`oxctl layout tiling SCHEME` switches to the tiling layout
with the scheme. `oxctl layout tiling scheme SCHEME` sets
the scheme without switching layouts. `oxctl layout tiling
next` and `prev` cycle the schemes; `oxctl layout tiling
query` prints them.

````{tab} Even
```{prompt} bash
oxctl layout tiling even
```

Each window gets the same height.

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |             B             |
|                                  |                           |
|                                  +---------------------------+
|                                  |                           |
|                                  |             C             |
|                                  |                           |
|                A                 +---------------------------+
|                                  |                           |
|                                  |             D             |
|                                  |                           |
|                                  +---------------------------+
|                                  |                           |
|                                  |             E             |
|                                  |                           |
+----------------------------------+---------------------------+
```
````

````{tab} Diminish
```{prompt} bash
oxctl layout tiling diminish
```
Each window gets 60% of the remaining height; windows shrink down the stack.

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |             B             |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                A                 +---------------------------+
|                                  |                           |
|                                  |             C             |
|                                  |                           |
|                                  +---------------------------+
|                                  |             D             |
|                                  +---------------------------+
|                                  |             E             |
+----------------------------------+---------------------------+
```
````

````{tab} Dwindle
```{prompt} bash
oxctl layout tiling dwindle
```

Each window takes half of the remaining area, alternating top and left.

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |             B             |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                 A                +-------------+-------------+
|                                  |             |             |
|                                  |             |      D      |
|                                  |             |             |
|                                  |      C      +-------------+
|                                  |             |             |
|                                  |             |      E      |
|                                  |             |             |
+----------------------------------+---------------------------+
```
````

````{tab} Spiral
```{prompt} bash
oxctl layout tiling spiral
```

Each window takes half of the remaining area, rotating top, right, bottom, left.

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |             B             |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                 A                +-------------+-------------+
|                                  |             |             |
|                                  |      E      |             |
|                                  |             |             |
|                                  +-------------+      C      |
|                                  |             |             |
|                                  |      D      |             |
|                                  |             |             |
+----------------------------------+---------------------------+
```
````

````{tab} Deck
```{prompt} bash
oxctl layout tiling deck
```

The stack windows lie on one pile. The most recently focused
window in the stack is visible.

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                 A                |       B [C, D, E]         |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |                           |
+----------------------------------+---------------------------+
```
````

````{tab} Monocle
```{prompt} bash
oxctl layout tiling monocle
```

Every window uses the full usable area.

```{svgbob}
+--------------------------------------------------------------+
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                        A [B, C, D, E]                        |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
+--------------------------------------------------------------+
```
````

#### Orientation

`oxctl layout tiling orientation left|right|up|down` sets
the position of the master area. Any scheme may have any
orientation.

````{tab} Left
```{prompt} bash
oxctl layout tiling orientation left
```

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |             B             |
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                A                 +---------------------------+
|                                  |                           |
|                                  |                           |
|                                  |                           |
|                                  |             C             |
|                                  |                           |
|                                  |                           |
|                                  |                           |
+----------------------------------+---------------------------+
```
````

````{tab} Right
```{prompt} bash
oxctl layout tiling orientation right
```

```{svgbob}
+---------------------------+----------------------------------+
|                           |                                  |
|                           |                                  |
|                           |                                  |
|             B             |                                  |
|                           |                                  |
|                           |                                  |
|                           |                                  |
+---------------------------+                A                 |
|                           |                                  |
|                           |                                  |
|                           |                                  |
|             C             |                                  |
|                           |                                  |
|                           |                                  |
|                           |                                  |
+---------------------------+----------------------------------+
```
````

````{tab} Up
```{prompt} bash
oxctl layout tiling orientation up
```

```{svgbob}
+--------------------------------------------------------------+
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                               A                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
+-------------------------------+------------------------------+
|                               |                              |
|                               |                              |
|               B               |              C               |
|                               |                              |
|                               |                              |
+-------------------------------+------------------------------+
```
````

````{tab} Down
```{prompt} bash
oxctl layout tiling orientation down
```

```{svgbob}
+-------------------------------+------------------------------+
|                               |                              |
|                               |                              |
|               B               |              C               |
|                               |                              |
|                               |                              |
+-------------------------------+------------------------------+
|                                                              |
|                                                              |
|                                                              |
|                                                              |
|                               A                              |
|                                                              |
|                                                              |
|                                                              |
|                                                              |
+--------------------------------------------------------------+
```
````

#### Master area

`oxctl layout tiling nmaster DELTA` sets how many windows
the master area holds. `oxctl layout tiling mfact DELTA`
sets the fraction of the output the master area uses. Both
take a signed delta or an absolute value.

```{prompt} bash
oxctl layout tiling nmaster 2
oxctl layout tiling mfact +0.05
```

### Scrolling

The scrolling layout puts each window in a column on a
strip. The strip scrolls through the output. Column
commands live under [`window column`](#window-column).

#### Alignment

The alignment controls how the strip scrolls when focus
changes.

| Alignment  | Behavior                                       |
|------------|------------------------------------------------|
| `visible`  | Scroll only when the focused column is cut off |
| `left`     | Put the focused column on the left edge        |
| `centered` | Keep the focused column in the center          |

Use `oxctl layout scrolling ALIGNMENT` to switch to the
scrolling layout with the given alignment. `oxctl layout
scrolling align visible|left|centered` sets the alignment
without switching.

#### Default width

`oxctl layout scrolling default-width DELTA` sets the
column width that new windows start with, as a fraction of
the output.

```{prompt} bash
oxctl layout scrolling default-width 0.5
```

#### Orientation

`oxctl layout scrolling orientation left|right|up|down`
sets the scroll direction and the position of the head of
the strip.

````{tab} Left
```{prompt} bash
oxctl layout scrolling orientation left # the default
```

```{svgbob}
+-------------------+------------------------+-----------------+
|                   |                        |                 |
|                   |                        |                 |
|                   |                        |                 |
|                   |            B           |                 |
|                   |                        |                 |
|                   |                        |                 |
|                   |                        |                 |
|         A         +------------------------+        D        |
|                   |                        |                 |
|                   |                        |                 |
|                   |                        |                 |
|                   |            C           |                 |
|                   |                        |                 |
|                   |                        |                 |
|                   |                        |                 |
+-------------------+------------------------+-----------------+
```
````

````{tab} Right
```{prompt} bash
oxctl layout scrolling orientation right
```

```{svgbob}
+-----------------+------------------------+-------------------+
|                 |                        |                   |
|                 |                        |                   |
|                 |                        |                   |
|                 |            B           |                   |
|                 |                        |                   |
|                 |                        |                   |
|                 |                        |                   |
|        D        +------------------------+         A         |
|                 |                        |                   |
|                 |                        |                   |
|                 |                        |                   |
|                 |            C           |                   |
|                 |                        |                   |
|                 |                        |                   |
|                 |                        |                   |
+-----------------+------------------------+-------------------+
```
````

````{tab} Up
```{prompt} bash
oxctl layout scrolling orientation up
```

```{svgbob}
+--------------------------------------------------------------+
|                                                              |
|                                                              |
|                              A                               |
|                                                              |
|                                                              |
+------------------------------+-------------------------------+
|                              |                               |
|                              |                               |
|               B              |               C               |
|                              |                               |
|                              |                               |
+------------------------------+-------------------------------+
|                                                              |
|                              D                               |
|                                                              |
|                                                              |
+--------------------------------------------------------------+
```
````

````{tab} Down
```{prompt} bash
oxctl layout scrolling orientation down
```

```{svgbob}
+--------------------------------------------------------------+
|                                                              |
|                                                              |
|                              D                               |
|                                                              |
+------------------------------+-------------------------------+
|                              |                               |
|                              |                               |
|               B              |               C               |
|                              |                               |
|                              |                               |
+------------------------------+-------------------------------+
|                                                              |
|                                                              |
|                              A                               |
|                                                              |
|                                                              |
+--------------------------------------------------------------+
```
````

### Floating

`oxctl layout floating` switches to the floating layout.
oxbow does not tile the windows; they keep the position and
size that you give them. New windows not matching any rules
spawn centered on the output.

#### Seed

`oxctl layout floating seed SEED` sets the size of a window
that becomes floating with no remembered placement. `SEED`
is a pixel value (`800`) or a percentage of the usable area
(`50%`, the default). The value applies to both width and
height.

## output

### output column

`oxctl output column width DELTA` adjusts every column on
the focused output by `DELTA`.

### output focus

Moves the seat focus to another output.

| Command                                 | Target                       |
|-----------------------------------------|------------------------------|
| `oxctl output focus left`               | The output in that direction |
| `oxctl output focus right`              | The output in that direction |
| `oxctl output focus up`                 | The output in that direction |
| `oxctl output focus down`               | The output in that direction |
| `oxctl output focus next`               | The next output              |
| `oxctl output focus prev`               | The previous output          |
| `oxctl output focus match --name REGEX` | The matching output          |

Every form accepts `--warp` and `--no-warp` to override the
[pointer-warp configuration](#input-pointer).

`match` selects by pattern. Each pattern is a regular
expression. `match` has the following flags:

- `--name REGEX` matches the output name
- `--label REGEX` matches each of the output's [labels](#output-label)
- `-i` makes the patterns case-insensitive
- `--cycle` focuses to the next match after the focused output
- `--invert` selects the outputs that do not match

### output label

A label is a free-form string on an output or a window.
Labels feed the `--label` pattern flag in matching, rules,
and lists.

```{prompt} bash
oxctl output label add primary --name DP-1
oxctl output label remove primary
```

`add` and `remove` act on the focused output when no
pattern is given. [`window label`](#window-label) does the
same for windows.

### output list

`oxctl output list` prints the active outputs with their
labels, focus, and capture state. The
[list flags](#input-list) apply.

### output overview

`oxctl output overview` toggles the overview grid: all
visible windows in a grid, in focus order.

`oxctl output overview cycle next` and `prev` move the
selection through the grid. With `--until-release MODS`,
the overview closes and the selection takes focus when you
release the modifiers:

```{prompt} bash
oxctl bind output overview cycle next --until-release=Super to Super+n
```

### output swap

Exchanges windows between two outputs.

| Command                             | Scope                                       |
|-------------------------------------|---------------------------------------------|
| `oxctl output swap tags SRC DST`    | The windows on `SRC`'s selected tags        |
| `oxctl output swap visible SRC DST` | All visible windows between `SRC` and `DST` |
| `oxctl output swap all SRC DST`     | Every window                                |

When `DST` is omitted the focused output will be used.
`SRC` may also be omitted when exactly two outputs are
present. `SRC` will then be the focused output and `DST` the
other output.

`--ring NAMES` may be given instead of `SRC` and `DST`.
The focused output will take the place of `SRC`. `DST` will
be the next output in the comma-separated ring. Add `--rev` to
walk the ring backward. See the
[getting started guide](../quick-start/getting-started.md#tag-swaps)
for a worked example.

## scratchpad

A scratchpad group holds windows that stash away and come
back on demand. `oxctl scratchpad toggle [NAME]` toggles
the group; the name defaults to `scratch`. When a member
window is visible, the toggle stashes all members.
Otherwise it summons all members to the focused output as
floating windows.

Windows join a group with
[`oxctl window scratchpad add`](#window-scratchpad) or the
`--scratchpad` [rule effect](#window-rules). A drop-down
terminal in the init script:

```bash
oxctl window rules add --app-id=dropdown --scratchpad=scratch --float
oxctl bind spawn 'oxctl scratchpad toggle || foot --app-id=dropdown' to Super+grave
```

## seat

`oxctl seat list` prints the active seats. The
[list flags](#input-list) apply.

## session

`oxctl session exit` ends the Wayland session.

## spawn

`oxctl spawn STRING` runs `STRING` through `/bin/sh -c`.
Use [`exec`](#exec) to run a command without a shell.

```{prompt} bash
oxctl spawn 'grim -g "$(slurp)"'
```

## subscribe

`oxctl subscribe [KIND]...` streams state changes as JSON
lines. Without arguments, all kinds stream. Each
subscription starts with a full snapshot, then sends one
line per change.

| Kind     | One event per                                     |
|----------|---------------------------------------------------|
| `tags`   | Output whose tag state changed                    |
| `window` | Window whose state changed                        |
| `layout` | Output whose layout or scheme changed             |
| `mode`   | Seat whose keymap mode changed                    |
| `focus`  | Seat whose focus changed                          |
| `output` | Output whose focus, labels, or capture state changed |

```{prompt} bash
oxctl subscribe tags layout --output DP-1
```

`--output NAME` limits output-keyed events to one output;
`mode` and `focus` events pass through. `-h`/`--human`
renders each event as one flat `key=value` line instead of
JSON.

When an output has no focused window, the `window` kind
sends a cleared record: `{"event":"window","output":NAME}`
with no other fields. Consumers can blank their display on
this record.

The [waybar integration](../integrations/waybar.md) builds
on `subscribe`.

## tag

Tags are numbered 1 to 32.

| Command                        | Effect                               |
|--------------------------------|--------------------------------------|
| `oxctl tag view TAGS`          | View the tag set                     |
| `oxctl tag toggle TAGS`        | Toggle the visibility of the tags    |
| `oxctl tag next`               | View the next tag                    |
| `oxctl tag prev`               | View the previous tag                |
| `oxctl tag previous-selection` | View the previously selected tag set |
| `oxctl tag query`              | Print the tag state of the output    |

Commands taking `TAGS` may be named directly as indices: a
single tag (7), a comma-separated list (1,3,8), or a range
(1-3,5). They may also be given as a bitmask in hexadecimal
(`0xff`), binary (`0b101`), or octal (`0o17`), where each
set bit selects one tag. Note that 7 means tag 7, while
`0b111` means tags 1, 2, and 3.

In addition to the above, `view` accepts the string literal
`occupied`. It represents all tags currently occupied by a
window.

`next` and `prev` wrap around. Skip empty tags with
`--occupied`.

## unbind

`oxctl unbind KEYBIND` removes a bind. `--mode MODE`
selects the keymap mode (default `normal`). The `KEYBIND`
grammar is under [bind](#bind).

## window

Every `window` command acts on a target. Without flags, the
target is the focused window. Pattern flags change the
target to the matching windows.

| Flag                 | Match                              |
|----------------------|------------------------------------|
| `--app-id REGEX`     | The window's app-id                |
| `--title REGEX`      | The window's title                 |
| `--identifier REGEX` | The window's identifier            |
| `--label REGEX`      | Each of the window's labels        |
| `-i`, `--ignore-case`| Make the patterns case-insensitive |

Each pattern is a regular expression. When you give more
than one, the window must match all of them. Selection
flags control which matches the command acts on:

| Flag            | Selection                                      |
|-----------------|------------------------------------------------|
| `--all`         | Act on every match                             |
| `--cycle`       | Act on the next match after the focused window |
| `--invert`      | Act on the windows that do not match           |
| `--focused`     | Search the focused output only                 |
| `--output NAME` | Search outputs matching `NAME` only            |

Without a selection flag, the command acts on the first
match. For example, focus the browser from any window:

```{prompt} bash
oxctl window focus match --app-id firefox
```

Close every terminal on the focused output:

```{prompt} bash
oxctl window close --app-id foot --focused --all
```

### window close

`oxctl window close` closes the target window(s).

### window column

Operates on the column of the target window in the
scrolling layout.

| Command                           | Effect                                          |
|-----------------------------------|-------------------------------------------------|
| `oxctl window column consume`     | Merge the next column into this column          |
| `oxctl window column release`     | Expel the target window into its own column     |
| `oxctl window column move next`   | Move the column toward the tail of the strip    |
| `oxctl window column move prev`   | Move the column toward the head of the strip    |
| `oxctl window column width DELTA` | Set the column width (`0.5`, `+0.1`, `-0.1`)    |
| `oxctl window column cycle`       | Cycle the width between `1/3`, `1/2`, and `2/3` |
| `oxctl window column default`     | Restore the tag's default width                 |

The default width for new windows is set with
[`oxctl layout scrolling default-width`](#scrolling).

### window drag

`oxctl window drag retile enabled|disabled` controls what
an interactive drag does to a tiled window on release. With
`enabled`, the window tiles again at the drop position.
With `disabled`, the window becomes floating. The drag
itself starts with [`window move drag`](#window-move) or
[`window resize drag`](#window-resize).

### window focus

| Command                          | Target                                   |
|----------------------------------|------------------------------------------|
| `oxctl window focus left`        | The window in that direction             |
| `oxctl window focus right`       | The window in that direction             |
| `oxctl window focus up`          | The window in that direction             |
| `oxctl window focus down`        | The window in that direction             |
| `oxctl window focus next`        | The next window in the stack             |
| `oxctl window focus prev`        | The previous window in the stack         |
| `oxctl window focus match FLAGS` | The window matching a [pattern](#window) |

Every form accepts `--warp` and `--no-warp` to override the
[pointer-warp configuration](#input-pointer).

### window label

`oxctl window label add LABEL` and `oxctl window label
remove LABEL` manage [labels](#output-label) on the target
window.

```{prompt} bash
oxctl window label add music --app-id spotify
oxctl window label remove music
```

### window list

`oxctl window list` prints the windows. The
[pattern flags](#window) filter the rows; the
[list flags](#input-list) format the table.

```{prompt} bash
oxctl window list --fields id,app_id,tags
```

### window move

Moves floating windows. Directions take a signed pixel or
percent value; `to` takes absolute values.

| Command                     | Effect                                          |
|-----------------------------|-------------------------------------------------|
| `oxctl window move left N`  | Move left by `N` (px or %)                      |
| `oxctl window move right N` | Move right by `N` (px or %)                     |
| `oxctl window move up N`    | Move up by `N` (px or %)                        |
| `oxctl window move down N`  | Move down by `N` (px or %)                      |
| `oxctl window move to X Y`  | Move to point (`X`, `Y`)                        |
| `oxctl window move drag`    | Start an interactive move on the focused window |

### window query

`oxctl window query` prints the focused window as a
one-row table. The [list flags](#input-list) apply.

### window resize

Same set as `window move`:

| Command                               | Effect                                            |
|---------------------------------------|---------------------------------------------------|
| `oxctl window resize left N`          | Grow or shrink the left edge by `N`               |
| `oxctl window resize right N`         | Grow or shrink the right edge by `N`              |
| `oxctl window resize up N`            | Grow or shrink the top edge by `N`                |
| `oxctl window resize down N`          | Grow or shrink the bottom edge by `N`             |
| `oxctl window resize to WIDTH HEIGHT` | Resize to `WIDTH` x `HEIGHT` (px or %)            |
| `oxctl window resize drag`            | Start an interactive resize on the focused window |

### Window rules

A rule matches new windows against regular expressions and
applies effects to them.

```{prompt} bash
oxctl window rules add --tags 3 --output=DP-3 --app-id=firefox
oxctl window rules list
oxctl window rules remove INDICES
```

`oxctl window rules list` prints the rules with their
indices. `oxctl window rules remove INDICES` deletes one or
more.

#### Patterns

A rule needs at least one pattern flag. When you give more
than one, the window must match all of them.

| Flag                 | Match                              |
|----------------------|------------------------------------|
| `--app-id REGEX`     | The window's app-id                |
| `--title REGEX`      | The window's title                 |
| `--identifier REGEX` | The window's identifier            |
| `--label REGEX`      | Each of the window's labels        |
| `-i`, `--ignore-case`| Make the patterns case-insensitive |

#### Effects

A rule needs at least one effect.

| Flag                   | Effect                                                                      |
|------------------------|-----------------------------------------------------------------------------|
| `--tags TAGS`          | Set the initial tags (same `TAGS` as [`tag view`](#tag))                    |
| `--output NAME`        | Send the window to the named output                                         |
| `--take`               | With `--output`: take the selected tags on the destination                  |
| `--float`              | Manage the window floating                                                  |
| `--tile`               | Manage the window tiled                                                     |
| `--fullscreen`         | Manage the window fullscreen                                                |
| `--windowed`           | Exit fullscreen                                                             |
| `--maximize`           | Manage the window maximized                                                 |
| `--fake-fullscreen`    | Fake fullscreen                                                             |
| `--resize-to W,H`      | Set the window size (`W,H` follow [`window resize to W H`](#window-resize)) |
| `--move-to X,Y`        | Set the window position (`X,Y` follow [`window move to X Y`](#window-move)) |
| `--label-as LABEL`     | Add `LABEL` to the window                                                   |
| `--scratchpad NAME`    | Put the window in scratchpad group `NAME`                                   |
| `--spawn-position POS` | Stack position: `master`, `prev`, `next`, or `end`                          |
| `--spawn-focus OPTION` | Whether the window takes focus on spawn                                     |
| `--sticky SCOPE`       | Sticky scope: `off`, `occupied`, or `all`                                   |
| `--swallow ROLE`       | Swallow role: `auto`, `terminal`, or `disabled`                             |

### window scratchpad

`oxctl window scratchpad add NAME` puts the target window
in [scratchpad](#scratchpad) group `NAME`. `oxctl window
scratchpad clear` removes it from its group.

### window send

Sends the target window to another output.

| Command                     | Destination                  |
|-----------------------------|------------------------------|
| `oxctl window send left`    | The output in that direction |
| `oxctl window send right`   | The output in that direction |
| `oxctl window send up`      | The output in that direction |
| `oxctl window send down`    | The output in that direction |
| `oxctl window send next`    | The next output              |
| `oxctl window send prev`    | The previous output          |
| `oxctl window send to NAME` | The named output             |

### window shift

`oxctl window shift next` and `prev` move the target
window through the tile stack, toward the tail or the head.
Both wrap at the ends.

`--occupied` restricts the shift to tags occupied by one or
more windows.

### window spawn

`oxctl window spawn position POSITION` sets where a new
window enters the stack.

| Position | Placement                            |
|----------|--------------------------------------|
| `master` | The head of the stack                |
| `prev`   | Before the focused window            |
| `next`   | After the focused window             |
| `end`    | The tail of the stack                |

`oxctl window spawn focus enabled|disabled` sets whether a
new window takes focus. The `--spawn-position` and
`--spawn-focus` [rule effects](#window-rules) override
both per window.

### window sticky

A sticky window stays visible when the viewed tags change.
`oxctl window sticky SCOPE` sets the scope.

| Scope      | Effect                                             |
|------------|----------------------------------------------------|
| `all`      | Keep the window on every tag view                  |
| `occupied` | Keep the window on views that hold other windows   |
| `off`      | Clear the sticky state                             |

### window tag

`oxctl window tag set TAGS` sets the tags of the target
window. `TAGS` is the same as [`tag view`](#tag).

`oxctl window tag shift next|prev` moves the window one tag
over. `--occupied` restricts the shift to tags occupied by
one or more windows.

### window toggle

Flips one state on the target window.

| Command                               | Effect                                               |
|---------------------------------------|------------------------------------------------------|
| `oxctl window toggle floating`        | Tiled or floating                                    |
| `oxctl window toggle fullscreen`      | Real fullscreen                                      |
| `oxctl window toggle fake-fullscreen` | Fullscreen dimensions without the state              |
| `oxctl window toggle maximize`        | Maximized                                            |
| `oxctl window toggle sticky all`      | [Sticky](#window-sticky) scope `all` or `off`        |
| `oxctl window toggle sticky occupied` | Sticky scope `occupied` or `off`                     |
| `oxctl window toggle swallow`         | Swallow the terminal under the window, or release it |
| `oxctl window toggle tag TAGS`        | The given tags                                       |

Swallowing: a terminal that spawns a graphical child hides
behind it until the child closes. The `--swallow ROLE`
[rule effect](#window-rules) sets the role per window:
`auto`, `terminal`, or `disabled`.

### window zoom

`oxctl window zoom` promotes the target window to master,
or swaps it with the next window when it is the master
already.

## wm

`oxctl wm close` stops oxbow and leaves river running.
