{
  description = "oxbow, a dynamic window manager for the Wayland compositor River, written in OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system: f system (nixpkgs.legacyPackages.${system}.extend self.overlays.default)
        );
    in
    {
      packages = forAllSystems (_: pkgs: { default = pkgs.oxbow; });

      formatter = forAllSystems (_: pkgs: pkgs.nixfmt);

      checks = forAllSystems (
        _: pkgs:
        (import ./checks.nix {
          inherit inputs pkgs;
          ocamlformat = pkgs.ocamlPackages.ocamlformat;
        })
        // {
          package-default = pkgs.oxbow;
        }
      );

      devShells = forAllSystems (
        system: pkgs: {
          default = import ./shell.nix {
            inherit pkgs;
            checks = self.checks.${system};
          };
        }
      );

      overlays.default = import ./nix/overlay.nix;
    };
}
