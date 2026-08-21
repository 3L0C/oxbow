# Defaults

This page documents the default configuration of oxbow.

## Settings

Each table lists the command that changes the setting. The
commands are documented in the [oxctl reference](./oxctl.md).

### Layout

The default layout is tiling. Layout settings are per tag;
these are the initial values for every tag.

| Setting                                 | Default   |
|-----------------------------------------|-----------|
| `oxctl layout tiling scheme`            | `even`    |
| `oxctl layout tiling orientation`       | `left`    |
| `oxctl layout tiling mfact`             | `0.55`    |
| `oxctl layout tiling nmaster`           | `1`       |
| `oxctl layout scrolling align`          | `visible` |
| `oxctl layout scrolling orientation`    | `left`    |
| `oxctl layout scrolling default-width`  | `0.5`     |
| `oxctl layout floating seed`            | `50%`     |

### Gaps

| Setting               | Default |
|-----------------------|---------|
| `oxctl gaps inner`    | `10`    |
| `oxctl gaps outer`    | `20`    |
| `oxctl gaps overview` | `10`    |

### Borders

| Setting                         | Default                                                                                                                                |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `oxctl border width`            | `4`                                                                                                                                    |
| `oxctl border color focused`    | `#7FB4CA` (<span style="background-color: #7FB4CA; width: 15px; height: 15px; display: inline-block; vertical-align: middle;"></span>) |
| `oxctl border color unfocused`  | `#727169` (<span style="background-color: #727169; width: 15px; height: 15px; display: inline-block; vertical-align: middle;"></span>) |
| `oxctl border color urgent`     | `#FF5D62` (<span style="background-color: #FF5D62; width: 15px; height: 15px; display: inline-block; vertical-align: middle;"></span>) |
| `oxctl border color swallowing` | `#98BB6C` (<span style="background-color: #98BB6C; width: 15px; height: 15px; display: inline-block; vertical-align: middle;"></span>) |
| `oxctl border color captured`   | `#957FB8` (<span style="background-color: #957FB8; width: 15px; height: 15px; display: inline-block; vertical-align: middle;"></span>) |

### Input

The cursor theme is unset; the system default applies.

| Setting                       | Default         |
|-------------------------------|-----------------|
| `oxctl input pointer follow`  | `not-scrolling` |
| `oxctl input pointer warp`    | `off`           |
| `oxctl input keyboard repeat` | `50 250`        |

### Windows

| Setting                      | Default   |
|------------------------------|-----------|
| `oxctl window spawn position`| `master`  |
| `oxctl window spawn focus`   | `enabled` |
| `oxctl window drag retile`   | `disabled`|

## Keybinds

| Keybind                 | Action                                                                     |
|-------------------------|----------------------------------------------------------------------------|
| `Super+Return`          | Spawn the [foot](https://codeberg.org/dnkl/foot) terminal                  |
| `Super+j`               | Focus the next window in the stack                                         |
| `Super+k`               | Focus the previous window in the stack                                     |
| `Super+q`               | Closes the focused window                                                  |
| `Super+Q`               | Exit the wayland session (i.e., return to greeter/tty/etc.)                |
| `Super+l`               | View the next occupied tag                                                 |
| `Super+h`               | View the previous occupied tag                                             |
| `Super+Tab`             | View the next tag                                                          |
| `Super+Shift+Tab`       | View the previous tag                                                      |
| `Super+t`               | Switch to the tiling layout                                                |
| `Super+s`               | Switch to the scrolling layout                                             |
| `Super+f`               | Switch to the floating layout                                              |
| `Super+v`               | Toggle fullscreen on the focused window                                    |
| `Super+space`           | [Zoom](./oxctl.md#window-zoom) the focused window                          |
| `Super+J`               | Move the focused window down the stack                                     |
| `Super+K`               | Move the focused window up the stack                                       |
| `Super+y`               | Switch to the even tiling layout                                           |
| `Super+i`               | Switch to the monocle tiling layout                                        |
| `Super+z`               | Switch to the scrolling layout, left aligned                               |
| `Super+x`               | Switch to the scrolling layout, center aligned                             |
| `Super+c`               | Switch to the scrolling layout, visible alignment                          |
| `Super+comma`           | Consume the next column                                                    |
| `Super+period`          | Release the focused window from the current column                         |
| `Super+Control+l`       | Move the focused column to the next slot                                   |
| `Super+Control+h`       | Move the focused column to the previous slot                               |
| `Super+minus`           | Decrease the focused column width by 10%                                   |
| `Super+equal`           | Increase the focused column width by 10%                                   |
| `Super+r`               | Cycle the column width between `1/3`, `1/2`, and `2/3` of the output width |
| `Super+R`               | Reset the column width to the default value                                |
| `Super+1` ... `Super+9` | View tag 1 ... 9                                                           |

## Pointer binds

| Bind              | Action                    |
|-------------------|---------------------------|
| `Super+Btn_left`  | Move the focused window   |
| `Super+Btn_right` | Resize the focused window |
