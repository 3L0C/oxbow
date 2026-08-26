# Configure River

oxbow requires [river](https://codeberg.org/river/river)
0.4.6 or later. This page shows how to install and configure
river to start oxbow.

## Install river

````{tab} Arch
```{prompt} bash
sudo pacman -S river
```
````

````{tab} Fedora
Fedora 45 and Rawhide carry river 0.4.6+:

```{prompt} bash
sudo dnf install river
```
````

````{tab} NixOS
Add the following module to your configuration:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.river ];
}
```

```{attention}
River is 0.4.5 in NixOS 26.05. Use nixpkgs unstable for 0.4.6+.
```
````

````{tab} Home Manager
Add the following module to your configuration:

```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.river ];
}
```

```{attention}
River is 0.4.5 in NixOS 26.05. Use nixpkgs unstable for 0.4.6+.
```

```{attention}
Do not use `wayland.windowManager.river`. It uses
river-classic.
```
````

````{tab} From source
Please see [river's README](https://codeberg.org/river/river#building)
for the necessary steps.
````

## Configure river

river runs the init script at `~/.config/river/init` on
startup.

````{tab} Non-Nix
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
Replace the module we created earlier:

```nix
{ pkgs, ... }:
let
  river-init = pkgs.writeShellScript "river-init" ''
    exec ${pkgs.oxbow}/bin/oxbow
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
Add the following module to your configuration:

```nix
{ pkgs, ... }:
{
  xdg.configFile."river/init" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${pkgs.oxbow}/bin/oxbow
    '';
  };
}
```
````
