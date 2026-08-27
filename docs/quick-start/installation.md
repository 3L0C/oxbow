# Installation

oxbow may be installed with [opam](https://opam.ocaml.org/),
or via Nix/NixOS using flakes.

```{attention}
oxbow requires [river](https://codeberg.org/river/river)
0.4.6 or later.  See {doc}`river` to install and configure
river.
```

## Opam

oxbow is packaged in opam's repository, making it easy to
install on many systems.

### Setup

Install opam and the necessary dependencies:

````{tab} Arch
```{prompt} bash
sudo pacman -S base-devel git rsync opam libxkbcommon
```
````

````{tab} Fedora
```{prompt} bash
sudo dnf install gcc make patch pkg-config git rsync opam libxkbcommon-devel
```
````

````{tab} Debian/Ubuntu
```{prompt} bash
sudo apt install build-essential pkg-config git rsync opam libxkbcommon-dev
```
````

````{tab} openSUSE
```{prompt} bash
sudo zypper install gcc make patch pkg-config git rsync opam libxkbcommon-devel
```
````

````{tab} Void
```{prompt} bash
sudo xbps-install -S base-devel git rsync opam libxkbcommon-devel
```
````

Once opam is installed run

```{prompt} bash
opam init
eval $(opam env)
```

```{note}
`opam init` asks to add a hook to your shell configuration.
If you answer yes, the hook adds packages installed through
opam to your shell's `PATH`. Without it, you must run `eval
$(opam env)` in every new shell.
```

### Install

```{prompt} bash
opam install oxbow
```

### Shell completion

oxbow provides completion scripts for `oxbow` and `oxctl`,
with support for bash and zsh.

Add the following to your shell configuration:

````{tab} Bash
```bash
# ~/.bashrc
source "$(opam var share)/bash-completion/completions/oxctl"
source "$(opam var share)/bash-completion/completions/oxbow"
```
````

````{tab} Zsh
```zsh
# ~/.zshrc, before compinit
fpath+=("$(opam var share)/zsh/site-functions")
```
````

## Nix/NixOS

You can install oxbow with or without flakes.

````{tab} NixOS
Add oxbow as a flake input, then put the package in
`environment.systemPackages`:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    oxbow = {
      url = "github:3L0C/oxbow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, oxbow, ... }: {
    nixosConfigurations.CHANGEME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [({ pkgs, ... }: {
        nixpkgs.overlays = [ oxbow.overlays.default ];
        environment.systemPackages = [ pkgs.oxbow ];
      })];
    };
  };
}
```

```{attention}
Replace `CHANGEME` with your system's hostname.
```

```{attention}
The rest of the instructions assume your config contains
`nixpkgs.overlays = [ oxbow.overlays.default ]`. This
overlay adds `oxbow` as a package to `pkgs`. If you'd rather
not add this overlay, you can use the following in place of
`pkgs.oxbow`:

`oxbow.packages.${pkgs.stdenv.hostPlatform.system}.default`

You may need to use
[`specialArgs`](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-flake-and-module-system#pass-non-default-parameters-to-submodules)
to pass either `inputs` or `oxbow` to additional modules.
```
````

````{tab} Home Manager
Use standalone Home Manager for a declarative install on a
distribution other than NixOS. Add oxbow as a flake input,
then put the package in `home.packages`:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oxbow = {
      url = "github:3L0C/oxbow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, oxbow, ... }: {
    homeConfigurations.CHANGEME = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ oxbow.overlays.default ];
      };
      modules = [({ pkgs, ... }: {
        home.packages = [ pkgs.oxbow ];
      })];
    };
  };
}
```

```{attention}
Replace `CHANGEME` with your username.
```

```{attention}
The rest of the instructions assume your config contains
the `pkgs` overlay shown above. This overlay adds `oxbow` as
a package to `pkgs`. If you'd rather not add this overlay,
you can use the following in place of `pkgs.oxbow`:

`oxbow.packages.${pkgs.stdenv.hostPlatform.system}.default`

You may need to use
[`extraSpecialArgs`](https://nix-community.github.io/home-manager/nix-flakes/standalone.html?highlight=extraspecialargs#standalone-setup)
to pass either `inputs` or `oxbow` to additional modules.
```
````

````{tab} Without flakes
```nix
{pkgs, ...}: let
  version = "0.1.0-1";

  oxbow-src = builtins.fetchTarball {
    url = "https://github.com/3L0C/oxbow/archive/refs/tags/v${version}.tar.gz";
    sha256 = "0spkvw0xv5yqs66idnwd6rcainf5bn1aqazb7yrnc4nji0x9bxfw";
  };
in {
  nixpkgs.overlays = [ (import "${oxbow-src}/nix/overlay.nix") ];
  environment.systemPackages = [ pkgs.oxbow ];
}
```

```{attention}
To upgrade, change to the desired `version`. Replace `sha256`
with `pkgs.lib.fakeHash`. Build the configuration once, and
replace `pkgs.lib.fakeHash` with the expected value.
```

```{note}
Replace `environment.systemPackages` with `home.packages`
for a Home Manager configuration.
```
````

````{tab} Nix package manager
For an imperative install into your user profile:

```{prompt} bash
nix profile install github:3L0C/oxbow
```

To upgrade later:

```{prompt} bash
nix profile upgrade oxbow
```

To try oxbow in a temporary shell without an install:

```{prompt} bash
nix shell github:3L0C/oxbow
```
````

### Shell completion

````{tab} NixOS
Make sure
`programs.bash.completion.enable`/`programs.zsh.enableCompletion`
are set to `true`.
````

````{tab} Home Manager
Make sure
`programs.bash.enableCompletion`/`programs.zsh.enableCompletion`
are set to `true`.
````

````{tab} Without flakes
Make sure
`programs.bash.enableCompletion`/`programs.zsh.enableCompletion`
are set to `true`.
````

````{tab} Nix package manager
For bash, make sure `~/.nix-profile/share` is in `$XDG_DATA_DIRS`:

```{prompt} bash
echo $XDG_DATA_DIRS | tr : '\n' | grep nix-profile
```

For zsh, add the following line before `compinit`:

```zsh
fpath+=(~/.nix-profile/share/zsh/site-functions)
```
````
