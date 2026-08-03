(lang dune 3.21)

(name ocdwm)

(version 0.1.0)

(generate_opam_files true)

(source
 (github 3L0C/ocdwm))

(license GPL-3.0-or-later)

(authors "3L0C")

(maintainers "3L0C")

(implicit_transitive_deps false)

(package
 (name ocdwm)
 (synopsis
  "ocdwm - dwm-like window manager for river 0.4.6+, written in OCaml")
 (depends
  (ocaml
   (>= 5.4))
  (dune
   (>= 3.23))
  (dune-build-info
   (>= 3.23))
  (cmdliner
   (>= 2.1))
  (eio
   (>= 1.2))
  (eio_main
   (>= 1.2))
  (fmt
   (>= 0.11))
  (landmarks-ppx
   (>= 1.7))
  (logs
   (>= 0.10))
  (ppx_yojson_conv
   (>= 0.17))
  (ppx_yojson_conv_lib
   (>= 0.17))
  (re
   (>= 1.12))
  (wayland
   (>= 2.3))
  (xkbcommon
   (>= 0.1))
  (yojson
   (>= 3.0))))

(package
 (name octl)
 (synopsis "octl - command-line interface for controlling ocdwm")
 (depends
  (ocaml
   (>= 5.4))
  (dune
   (>= 3.21))
  (cmdliner
   (>= 2.1))
  (dune-build-info
   (>= 3.21))
  (eio
   (>= 1.3))
  (eio_posix
   (>= 1.3))
  (fmt
   (>= 0.11))
  (logs
   (>= 0.10))
  (ppx_yojson_conv
   (>= 0.17))
  (ppx_yojson_conv_lib
   (>= 0.17))
  (re
   (>= 1.12))
  (yojson
   (>= 3.0))))
