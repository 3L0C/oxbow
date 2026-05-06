{
  lib,
  ocamlPackages,
}:
ocamlPackages.buildDunePackage {
  pname = "ocdwm";
  version = "0.1.0-dev";
  duneVersion = "3";
  src = lib.cleanSource ./.;

  buildInputs = builtins.attrValues {
    inherit
      (ocamlPackages)
      wayland
      eio
      eio_main
      yojson
      cmdliner
      xkbcommon
      landmarks
      landmarks-ppx
      ppxlib
      ppx_yojson_conv
      ;
  };

  nativeBuildInputs = builtins.attrValues {
    inherit
      (ocamlPackages)
      wayland
      xkbcommon
      ;
  };

  meta = {
    description = "ocdwm - dwm-like window manager for river 0.4.x, written in OCaml";
    homepage = "https://github.com/3L0C/ocdwm";
    license = lib.licenses.gpl3Plus;
    mainProgram = "ocdwm";
    platforms = lib.platforms.linux;
  };
}
