{
  lib,
  ocamlPackages,
}:
ocamlPackages.buildDunePackage {
  pname = "oxbow";
  version = lib.fileContents ./VERSION;
  duneVersion = "3";
  minimalOCamlVersion = "5.4";

  src = lib.cleanSource ./.;

  propagatedBuildInputs = with ocamlPackages; [
    cmdliner
    dune-build-info
    eio
    eio_main
    eio_posix
    fmt
    landmarks
    landmarks-ppx
    logs
    ppx_yojson_conv
    re
    wayland
    xkbcommon
    yojson
  ];

  nativeBuildInputs = [ ocamlPackages.cmdliner ];

  doCheck = true;
  checkInputs = [ ocamlPackages.cstruct ];

  meta = {
    description = "oxbow, a dynamic window manager for the Wayland compositor River, written in OCaml";
    homepage = "https://github.com/3L0C/oxbow";
    license = lib.licenses.gpl3Plus;
    mainProgram = "oxbow";
    platforms = lib.platforms.linux;
  };
}
