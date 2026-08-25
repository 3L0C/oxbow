{
  inputs,
  pkgs,
  ocamlformat,
  ...
}: {
  pre-commit-check = inputs.git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
    src = ./.;

    hooks = {
      nixfmt.enable = true;

      ocamlformat = {
        enable = true;
        name = "ocamlformat";
        description = "Format OCaml files with ocamlformat";
        entry = "${ocamlformat}/bin/ocamlformat --inplace";
        types = ["ocaml"];
      };

      check-merge-conflicts = {
        enable = true;
        excludes = ["^protocols/.*\\.ml$"];
      };
      end-of-file-fixer = {
        enable = true;
        excludes = [
          "^protocols/.*\\.ml$"
          "^test/.*\\.expected$"
        ];
      };
      trim-trailing-whitespace = {
        enable = true;
        excludes = [
          "^protocols/.*\\.ml$"
          "^test/.*\\.expected$"
        ];
      };
    };
  };
}
