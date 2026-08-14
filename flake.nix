{
  description = "oxbow - dynamic window manager for the river Wayland compositor, written in OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };

    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs = {
        opam-repository.follows = "opam-repository";
        nixpkgs.follows = "nixpkgs";
      };
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    flake-utils,
    opam-nix,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        localPackagesQuery = builtins.mapAttrs (_: pkgs.lib.last) (on.listRepo (on.makeOpamRepo ./.));
        devPackagesQuery = {
          # You can add "development" packages here. They will get added to the
          # devShell automatically.
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          odoc = "*";
        };
        query =
          devPackagesQuery
          // {
            ## You can force versions of certain packages here, e.g:
            ## - force the ocaml compiler to be taken from opam-repository:
            ocaml-base-compiler = "*";
            ## - or force the compiler to be taken from nixpkgs and be a certain version:
            # ocaml-system = "4.14.0";
            ## - or force ocamlfind to be a certain version:
            # ocamlfind = "1.9.2";
          };
        scope = on.buildOpamProject' {} ./. query;
        overlay = final: prev: {
          # You can add overrides here
        };
        scope' = scope.overrideScope overlay;
        pre-commit-check =
          (import ./checks.nix {
            inherit inputs pkgs;
            ocamlformat = scope'.ocamlformat;
          }).pre-commit-check;
        # Packages from devPackagesQuery
        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
        # Packages in this workspace
        packages = pkgs.lib.getAttrs (builtins.attrNames localPackagesQuery) scope';
      in {
        legacyPackages = scope';

        formatter = pkgs.alejandra;

        checks = {
          inherit pre-commit-check;
          package-oxbow = scope'.oxbow;
        };

        # inherit packages;

        ## If you want to have a "default" package which will be built with just
        ## `nix build`, do this instead of `inherit packages;`:
        packages =
          packages
          // {
            default = packages.oxbow;
          };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues packages;
          buildInputs =
            devPackages
            ++ pre-commit-check.enabledPackages
            ++ [
              # You can add packages from nixpkgs here
              pkgs.gnumake
              pkgs.svgbob
              (pkgs.python3.withPackages (ps: [
                ps.sphinx
                ps.myst-parser
                ps.furo
                ps.sphinx-copybutton
                ps.sphinx-prompt
                ps.sphinx-autobuild
                ps.sphinx-design
                ps.sphinx-inline-tabs
              ]))
            ];

          shellHook = ''
            ${pre-commit-check.shellHook}

            if [ -n "$BASH_VERSION" ] && shopt -q progcomp 2>/dev/null && command -v cmdliner >/dev/null 2>&1; then
              source <(cmdliner tool-completion --standalone-completion bash oxbow)
              source <(cmdliner tool-completion --standalone-completion bash oxctl)
            fi

            echo ""
            echo "oxbow development environment"
            echo "============================="
            echo ""
            echo "Build commands:"
            echo "  dune build                  - Build the project"
            echo "  dune build @check           - Type-check without linking"
            echo "  dune test                   - Run tests"
            echo "  dune clean                  - Remove _build directory"
            echo ""
            echo "Development tools:"
            echo "  utop                        - OCaml REPL with project libs loaded"
            echo "  ocamlformat <file>          - Format an OCaml file"
            echo "  dune build @fmt             - Check formatting of all files"
            echo "  dune promote                - Apply formatter suggestions"
            echo "  odoc                        - Generate documentation"
            echo ""
            echo "Sphinx documentation:"
            echo "  make docs                   - Build the HTML docs"
            echo "  make docs-html              - Build HTML docs into \$(DOCS_BUILD)/html"
            echo "  make docs-serve             - Build HTML and serve at localhost:8000"
            echo "  make docs-live              - Live-reload HTML build (sphinx-autobuild)"
            echo "  make docs-linkcheck         - Verify all internal and external links"
            echo "  make docs-clean             - Remove \$(DOCS_BUILD)"
            echo "  make man                    - Regenerate bin/oxctl/oxctl.1 from the built oxctl"
            echo ""
            echo "Code quality:"
            echo "  pre-commit run --all-files  - Run all pre-commit hooks"
            echo "  nix fmt                     - Format Nix files"
            echo "  nix flake check             - Run all flake checks"
            echo ""
          '';
        };
      }
    );
}
