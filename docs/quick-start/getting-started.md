# Getting Started

With oxbow, oxctl, and river installed you are ready to
begin configuration.

```{attention}
Please see river's [list of useful software](https://codeberg.org/river/wiki/src/branch/main/pages/useful-software.md)
for additional tools (launcher, bar, lock screen, wallpaper).
```

## Init configuration

oxbow runs the init script at `~/.config/oxbow/init` on
startup.

````{tab} opam
Create `~/.config/oxbow/init` script:

```bash
#!/bin/sh
eval "$(opam env)"
oxctl bind spawn foot to Super+Return
```

Make the script executable:

```{prompt} bash
chmod +x ~/.config/oxbow/init
```
````

````{tab} NixOS
Extend the module from [NixOS River setup](./river.md#configure-river):

```{code-block} nix
:emphasize-lines: 4-7,9
{ pkgs, oxbow, ... }:
let
  oxbow-pkg = oxbow.packages.${pkgs.stdenv.hostPlatform.system}.default;
  oxctl = "${oxbow-pkg}/bin/oxctl";
  oxbow-init = pkgs.writeShellScript "oxbow-init" ''
    ${oxctl} bind spawn foot to Super+Return
  '';
  river-init = pkgs.writeShellScript "river-init" ''
    exec ${oxbow-pkg}/bin/oxbow -c ${oxbow-init}
  '';
  wrapped-river = pkgs.symlinkJoin {
    name = "river";
    paths = [ pkgs.river ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/river --add-flags "-c ${river-init}"
    '';
  };
in
{
  environment.systemPackages = [ wrapped-river ];
}
```

```{attention}
`oxbow -c` overrides `~/.config/oxbow/init`. Use one or the other.
```
````

````{tab} Home Manager
```{code-block} nix
{ pkgs, oxbow, ... }:
let
  oxbow-pkg = oxbow.packages.${pkgs.stdenv.hostPlatform.system}.default;
  oxctl = "${oxbow-pkg}/bin/oxctl";
in
{
  xdg.configFile = {
    "oxbow/init" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${oxctl} bind spawn foot to Super+Return
      '';
    };
  };
}
```
````

oxbow also has default keybinds. The init script adds to
them. See the defaults
[here](../reference/defaults.md#keybinds) for the full list.

## First launch

Start river; oxbow starts with it and runs the init script.

These keybinds are enough for a first session.

| Keybind        | Action                                                    |
|----------------|-----------------------------------------------------------|
| `Super+Return` | Spawn the [foot](https://codeberg.org/dnkl/foot) terminal |
| `Super+j`      | Focus the next window in the stack                        |
| `Super+k`      | Focus the previous window in the stack                    |
| `Super+q`      | Close the focused window                                  |
| `Super+Q`      | Exit the Wayland session and return to greeter or TTY     |

## Settings

Open up foot and run the following commands

```{prompt} bash
oxctl gaps inner 0
oxctl gaps outer 0
```

Configure the borders as well

```{prompt} bash
oxctl border width 2
oxctl border color focused '#bb9af7'
oxctl border color unfocused '#71799d'
oxctl border color urgent '#f7768e'
```

Configure input devices

```{prompt} bash
oxctl input pointer follow always
oxctl input pointer warp on
oxctl input keyboard repeat 50 250
```

## Tags

Move windows between tags

```{prompt} bash
oxctl window tag set 2
```

View multiple tags at once

```{prompt} bash
oxctl tag view 1,2
```

## Layouts

oxbow has three layouts:

- **Tiling**: `Super+t`
- **Scrolling**: `Super+s`
- **Floating**: `Super+f`

### Tiling

The tiling layout works like dwm. One master window on the
left, the rest stacked evenly on the right. Open five
windows then change the orientation, and stacking
arrangement

```{prompt} bash
oxctl layout tiling orientation right
oxctl layout tiling spiral
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
+-------------+-------------+                 A                |
|             |             |                                  |
|             |      E      |                                  |
|             |             |                                  |
|      C      +-------------+                                  |
|             |             |                                  |
|             |      D      |                                  |
|             |             |                                  |
+---------------------------+----------------------------------+
```

Switch back to the default

```{prompt} bash
oxctl layout tiling orientation left
oxctl layout tiling even
```

```{svgbob}
+----------------------------------+---------------------------+
|                                  |                           |
|                                  |            B              |
|                                  |                           |
|                                  +---------------------------+
|                                  |                           |
|                                  |            C              |
|                                  |                           |
|                A                 +---------------------------+
|                                  |                           |
|                                  |            D              |
|                                  |                           |
|                                  +---------------------------+
|                                  |                           |
|                                  |            E              |
|                                  |                           |
+----------------------------------+---------------------------+
```

See all the arrangements [here](../reference/oxctl.md#tiling).

### Scrolling

Switch to the scrolling layout with `Super+s`. There are
three alignments: Visible, Left, and Centered

````{tab} Visible

The visible alignment will only rescroll when focusing a
column that is not fully visible.

```{prompt} bash
oxctl layout scrolling visible
```

```{svgbob}
+----------------------------+------------------------------+--+
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|             A              |         B [Focused]          | C|
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
|                            |                              |  |
+----------------------------+------------------------------+--+
```

When column B is focused, changing focus to column C will
scroll the strip so that C's right border is aligned with
the right side of the output.

````

````{tab} Left

The left alignment puts the left edge of the focused column
on the left edge of the output.

```{prompt} bash
oxctl layout scrolling left
```

```{svgbob}
+------------------------------+----------------------------+--+
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|         B [Focused]          |             C              | D|
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
|                              |                            |  |
+------------------------------+----------------------------+--+
```
````

````{tab} Centered

The centered alignment keeps the focused column in the
center of the output.

```{prompt} bash
oxctl layout scrolling centered
```

```{svgbob}
+---------------+------------------------------+---------------+
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|       A       |         B [Focused]          |       C       |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
|               |                              |               |
+---------------+------------------------------+---------------+
```
````

The scrolling layout can also scroll vertically. See
[scrolling orientation](../reference/oxctl.md#scrolling) in
the reference.

### Floating

In the floating layout, oxbow does not tile windows. Windows
keep the position and size that you give them.

## Overview

Overview shows all visible windows and cycles focus through
them, like alt-tab. Test it with these binds


```{prompt} bash
oxctl bind output overview cycle next --until-release=Super to Super+n
oxctl bind output overview cycle prev --until-release=Super to Super+Shift+n
```

Hold `Super` and press `n` to cycle. Release `Super` to
select the focused window.

The overview looks like this

```{svgbob}
+--------------------+--------------------+--------------------+
|                    |                    |                    |
|                    |                    |                    |
|                    |                    |                    |
|         A          |         B          |         C          |
|                    |                    |                    |
|                    |                    |                    |
|                    |                    |                    |
+--------------------+--------------------+--------------------+
|                    |                    |                    |
|                    |                    |                    |
|                    |                    |                    |
|         D          |         E          |         F          |
|                    |                    |                    |
|                    |                    |                    |
|                    |                    |                    |
+--------------------+--------------------+--------------------+
```

When there are more than six windows on an output, the grid
scrolls vertically. Continue pressing `Super+n` to scroll to
offscreen windows.

```{note}
The overview is displayed in focus order.
```

## Multiple outputs

List the output names

```{prompt} bash
oxctl output list
```

### Output focus

```{prompt} bash
oxctl bind output focus match --name HDMI-A-1 to Super+semicolon
oxctl bind output focus match --name DP-1 to Super+apostrophe
```

Each bind moves focus to the named output. Use the output
names for your system.

### Tag swaps

```{prompt} bash
oxctl bind output swap tags --ring HDMI-A-1,DP-3,DP-1 to Super+e
oxctl bind output swap tags --ring HDMI-A-1,DP-3,DP-1 --rev to Super+w
```

Each bind swaps the windows on the visible tags through the
outputs in the ring.

Each press swaps the focused output's windows with the next
output in the ring. For example, start with these windows on
tag 1:

| Output     | Windows |
|------------|---------|
| `HDMI-A-1` | F       |
| `DP-3`     | A, B    |
| `DP-1`     | C, D, E |

1. Focus `DP-3` and press `Super+e`. `DP-3` now has C, D,
   and E. `DP-1` has A and B.
2. Press `Super+e` again. All windows are back where they
   started.
3. Focus `HDMI-A-1` and press `Super+w`. `HDMI-A-1` has C,
   D, and E. `DP-1` now has F.

## Window rules

```{prompt} bash
oxctl window rules add --tags 3 --output=DP-3 --app-id=firefox
oxctl window rules add --tags 2 --output=DP-3 --app-id=emacs
oxctl window rules add --tags 9 --app-id=org.keepassxc.KeePassXC
oxctl window rules add --tags 4 --output=DP-3 --app-id=steam
```

These rules set the initial tags and output for each window
matching the given app-id.

View existing rules

```{prompt} bash $ auto
$ oxctl window rules list
INDEX  PATTERN                                        EFFECTS
0      app_id=firefox case=sensitive                  output=name=DP-3 policy=keep tags=concrete 4
1      app_id=emacs case=sensitive                    output=name=DP-3 policy=keep tags=concrete 2
2      app_id=org.keepassxc.KeePassXC case=sensitive  tags=concrete 256
3      app_id=steam case=sensitive                    output=name=DP-3 policy=keep tags=concrete 8
```

Delete rules

```{prompt} bash $ auto
$ oxctl window rules remove 0,2
$ oxctl window rules list
INDEX  PATTERN                                        EFFECTS
0      app_id=emacs case=sensitive                    output=name=DP-3 policy=keep tags=concrete 2
1      app_id=steam case=sensitive                    output=name=DP-3 policy=keep tags=concrete 8
```

Rules can also define the position and dimension of windows.
Matching can also be done on a window's title with
`--title`. `--app-id` and `--title` are regular expressions.
See [the reference](../reference/oxctl.md#window-rules) for
the full set of window rules.

## Go deeper

`oxctl` can also query the state of windows, tags, and
outputs. It can subscribe to events for scripts and status
bars. See:

- [oxctl reference](../reference/oxctl.md)
- [Waybar integration](../integrations/waybar.md)

```{note}
Pass `--help` to any `oxctl` command to see its subcommands
and options.
```
