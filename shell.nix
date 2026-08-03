{
  pkgs ? import <nixpkgs> {},
  checks ? {},
  ...
}: let
  ocdwm-package = pkgs.callPackage ./default.nix {};

  hasPreCommit = checks ? pre-commit-check;
  preCommitPackages =
    if hasPreCommit
    then checks.pre-commit-check.enabledPackages
    else [];
  preCommitHook =
    if hasPreCommit
    then checks.pre-commit-check.shellHook
    else "";
in
  pkgs.mkShell {
    buildInputs = [pkgs.bashInteractive] ++ preCommitPackages;

    inputsFrom = [ocdwm-package];

    nativeBuildInputs = builtins.attrValues {
      inherit
        (pkgs)
        git
        pre-commit
        pkg-config
        ;

      inherit
        (pkgs.ocamlPackages)
        ocaml-lsp
        ocamlformat
        utop
        odoc
        dune-release
        ;
    };

    shellHook = ''
      ${preCommitHook}

      echo ""
      echo "ocdwm development environment"
      echo "============================="
      echo ""
      echo "Build commands:"
      echo "  dune build              - Build the project"
      echo "  dune build @check       - Type-check without linking"
      echo "  dune test               - Run tests"
      echo "  dune clean              - Remove _build directory"
      echo ""
      echo "Development tools:"
      echo "  utop                    - OCaml REPL with project libs loaded"
      echo "  ocamlformat <file>      - Format an OCaml file"
      echo "  dune build @fmt         - Check formatting of all files"
      echo "  dune promote            - Apply formatter suggestions"
      echo "  odoc                    - Generate documentation"
      echo ""
      echo "Code quality:"
      echo "  pre-commit run --all-files  - Run all pre-commit hooks"
      echo "  nix fmt                     - Format Nix files"
      echo "  nix flake check             - Run all flake checks"
      echo ""
    '';
  }
