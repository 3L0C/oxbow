{
  inputs,
  pkgs,
  ...
}: {
  pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
    src = ./.;

    hooks = {
      alejandra.enable = true;

      ocamlformat = {
        enable = true;
        name = "ocamlformat";
        description = "Format OCaml files with ocamlformat";
        entry = "${pkgs.ocamlPackages.ocamlformat}/bin/ocamlformat --inplace";
        types = ["ocaml"];
      };

      check-merge-conflicts = {
        enable = true;
        excludes = ["^protocol/.*\\.ml$"];
      };
      end-of-file-fixer = {
        enable = true;
        excludes = ["^protocol/.*\\.ml$"];
      };
      trim-trailing-whitespace = {
        enable = true;
        excludes = ["^protocol/.*\\.ml$"];
      };
    };
  };
}
