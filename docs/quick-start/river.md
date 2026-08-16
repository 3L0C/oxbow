# Configure River

oxbow requires [river](https://codeberg.org/river/river)
0.4.6 or later. This page shows how to install and configure
river to start oxbow.

## Install river

Distribution packages differ:

- Arch: `sudo pacman -S river`.
- Fedora: 0.4.6+ is in Fedora 45 and Rawhide only.
- Debian, Ubuntu, openSUSE, and Void: no 0.4.6 package at
  the time of writing. Build river from source; see the
  [river README](https://codeberg.org/river/river).
- Nix: `pkgs.river` in nixpkgs unstable is 0.4.6+. Add it
  next to oxbow in your configuration, or run
  `nix profile install nixpkgs#river`.

## Configure river

river runs the init script at `~/.config/river/init` on
startup

```bash
#!/bin/sh
eval "$(opam env)"
exec oxbow
```

Make the script executable:

```{prompt} bash
chmod +x ~/.config/river/init
```

Home Manager users can write the file declaratively:

```nix
xdg.configFile."river/init" = {
  executable = true;
  text = ''
    #!/bin/sh
    oxbow
  '';
};
```
