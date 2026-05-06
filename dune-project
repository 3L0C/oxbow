(lang dune 3.21)

(name ocdwm)

(generate_opam_files true)

(source
 (github 3L0C/ocdwm))

(license GPL-3.0-or-later)

(authors "3L0C")

(maintainers "3L0C")

(package
 (name ocdwm)
 (synopsis
  "ocdwm - dwm-like window manager for river 0.4.x, written in OCaml")
 (depends
  (ocaml
   (>= 5.4))
  (dune
   (>= 3.21))
  (wayland
   (>= 2.2))
  (eio_main
   (>= 1.2))
  (yojson
   (>= 2.0))
  (ppx_yojson_conv
   (>= 0.16))
  (cmdliner
   (>= 1.3))
  (xkbcommon
   (>= 0.1))
  (logs
   (>= 0.7))
  (fmt
   (>= 0.9))
  (landmarks-ppx
   (>= 1.4))))
