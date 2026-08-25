final: prev:
let
  ocamlPackages = prev.ocamlPackages.overrideScope (
    ofinal: _: {
      xkbcommon = ofinal.callPackage ./xkbcommon.nix { };
    }
  );
in
{
  oxbow = final.callPackage ../default.nix { inherit ocamlPackages; };
}
