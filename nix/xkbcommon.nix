{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libxkbcommon,
  pkg-config,
  alcotest,
}:
buildDunePackage {
  pname = "xkbcommon";
  version = "0.1.0-unstable-20260825";
  duneVersion = "3";
  minimalOCamlVersion = "4.14";

  src = fetchFromGitHub {
    owner = "talex5";
    repo = "xkbcommon";
    rev = "bcb74feb2a32a41e612ef28c26755181a9ddcff9";
    hash = "sha256-tyR+X6H7F9U7ylnxoGulmQEe5VANvb0vKqitFT+zxUc=";
  };

  buildInputs = [
    dune-configurator
    libxkbcommon
  ];

  nativeBuildInputs = [ pkg-config ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "OCaml bindings to libxkbcommon";
    homepage = "https://github.com/talex5/xkbcommon";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
