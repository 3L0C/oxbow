{
  description = "ocdwm - dwm-like window manager for river 0.4.x, written in OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xkbcommon-ocaml = {
      url = "github:3L0C/xkbcommon";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              ocamlPackages = prev.ocamlPackages.overrideScope (ofinal: oprev: {
                xkbcommon = inputs.xkbcommon-ocaml.packages.${system}.default;
              });
            })
          ];
        };

        ocdwm-package = pkgs.callPackage ./default.nix {};
      in {
        packages = {
          default = ocdwm-package;
          ocdwm = ocdwm-package;
        };

        apps.default = {
          type = "app";
          program = "${ocdwm-package}/bin/ocdwm";
        };

        formatter = pkgs.alejandra;

        checks =
          (import ./checks.nix {inherit inputs pkgs;})
          // {
            package-default = ocdwm-package;
          };

        devShells.default = import ./shell.nix {
          inherit pkgs;
          checks = self.checks.${system};
        };
      }
    )
    // {
      overlays.default = final: prev: {
        ocdwm = final.callPackage ./default.nix {};
      };
    };
}
