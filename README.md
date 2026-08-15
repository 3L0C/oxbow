# <img src="docs/_static/favicon.svg" width="32" alt="oxbow logo"> oxbow

[demo](https://github.com/user-attachments/assets/9e5fdfd8-c656-454c-b4a3-192392800787)

oxbow is a dynamic tiling window manager for the Wayland
compositor [River](https://codeberg.org/river/river),
written in OCaml. Inspired by
[dwm](https://dwm.suckless.org/) and river-classic, oxbow
aims to manage your windows predictably. Configure it with a
simple init script, and control it with `oxctl` from your
own scripts.

## Features

- **Tags**: Group windows with tag sets, per-tag layouts,
  and operations on tags.
- **Layouts**: dwm-like tiling, niri-ish scrolling in four
  orientations, "alt-tab" overview, and pure floating.
- **Windows**: Scratchpads, sticky windows, user labels,
  window swallowing, and drag with retile.
- **Rules**: Regex window matching to configure initial
  tags, output, floating, size, and presentation.
- **IPC**: Control windows, configure tags, query objects,
  and subscribe to events.

## Documentation

Full documentation is available at
[oxbow-wm.readthedocs.io](https://oxbow-wm.readthedocs.io/).

- [Installation](https://oxbow-wm.readthedocs.io/en/latest/quick-start/installation.html)
- [River Setup](https://oxbow-wm.readthedocs.io/en/latest/quick-start/river.html)
- [Getting Started](https://oxbow-wm.readthedocs.io/en/latest/quick-start/getting-started.html)
- [oxctl Reference](https://oxbow-wm.readthedocs.io/en/latest/reference/oxctl.html)
- [Defaults](https://oxbow-wm.readthedocs.io/en/latest/reference/defaults.html)
- [Waybar Integration](https://oxbow-wm.readthedocs.io/en/latest/integrations/waybar.html)

## Installation

oxbow requires [river](https://codeberg.org/river/river)
0.4.6 or later.

Install with opam:

```bash
opam pin add oxbow https://github.com/3L0C/oxbow.git
```

Or with Nix:

```bash
nix profile install github:3L0C/oxbow
```

See the
[installation guide](https://oxbow-wm.readthedocs.io/en/latest/quick-start/installation.html)
for build dependencies, NixOS and Home Manager
configuration, and shell completion.

## Contributing

Contributions are welcome! If you find any issues or have
suggestions for improvements, please open an issue or submit
a pull request.

## AI disclosure

Claude Code was used in the following ways:

- design discussions
- debugging

I've written and will continue to write the code.

Note that
[river](https://codeberg.org/river/river#strict-no-llm-no-ai-policy)
has a strict no LLM / no AI policy. The policy forbids
generative AI for all contributions to river, including bug
reports and comments on the issue tracker. Do not carry
material from this repository into a river contribution.
