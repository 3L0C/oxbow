# oxbow

oxbow is a dynamic tiling window manager for the Wayland
compositor [River](https://codeberg.org/river/river),
written in OCaml. Inspired by
[dwm](https://dwm.suckless.org/) and river-classic, oxbow
aims to manage your windows predictably. Configure it with a
simple init script, and control it with `oxctl` from your
own scripts.

## Features

- **Tags**: Group windows with tag sets, per-tag
  layouts, and operations on tags.
- **Layouts**: dwm-like tiling, niri-ish scrolling in four
  orientations, "alt-tab" overview, and pure floating.
- **Windows**: Scratchpads, sticky windows, user labels,
  window swallowing, and drag with retile.
- **Rules**: Regex window matching to configure initial
  tags, output, floating, size, and presentation.
- **IPC**: Control windows, configure tags, query objects,
  and subscribe to events.

```{toctree}
:hidden:

quick-start/installation
quick-start/river
quick-start/getting-started
reference/oxctl
reference/defaults
integrations/waybar
```
