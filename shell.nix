{
  pkgs ? import <nixpkgs> { },
  checks ? { },
  ...
}:
let
  hasPrecommit = checks ? pre-commit-check;

  preCommitPackages = if hasPrecommit then checks.pre-commit-check.enabledPackages else [ ];

  preCommitHook = if hasPrecommit then checks.pre-commit-check.shellHook else "";
in
pkgs.mkShell {
  buildInputs = [ pkgs.bashInteractive ] ++ preCommitPackages;

  inputsFrom = [ pkgs.oxbow ];

  nativeBuildInputs =
    builtins.attrValues {
      inherit (pkgs)
        git
        pre-commit
        pkg-config
        gnumake
        svgbob
        ;

      inherit (pkgs.ocamlPackages)
        ocaml-lsp
        ocamlformat
        utop
        odoc
        ;
    }
    ++ [
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
    ${preCommitHook}

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
}
