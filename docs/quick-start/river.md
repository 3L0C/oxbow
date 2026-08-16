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
startup.

````{tab} opam
Create `~/.config/river/init` script:

```bash
#!/bin/sh
eval "$(opam env)"
exec oxbow
```

Make the script executable:

```{prompt} bash
chmod +x ~/.config/river/init
```
````

````{tab} NixOS
```nix
{ pkgs, oxbow, ... }:
let
  oxbow-pkg = oxbow.packages.${pkgs.stdenv.hostPlatform.system}.default;
  river-init = pkgs.writeShellScript "river-init" ''
    exec ${oxbow-pkg}/bin/oxbow
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
Use `wrapped-river`, not `pkgs.river`, in display manager
entries and systemd services. Only `wrapped-river` runs the
init script.
```
````

````{tab} Home Manager
```nix
{ pkgs, oxbow, ... }:
let
  oxbow-pkg = oxbow.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  xdg.configFile."river/init" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${oxbow-pkg}/bin/oxbow
    '';
  };
}
```
````
