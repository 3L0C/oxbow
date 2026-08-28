(lang dune 3.22)

(name oxbow)

(version 0.1.1)

(generate_opam_files true)

(source
 (github 3L0C/oxbow))

(license GPL-3.0-or-later)

(authors "3L0C")

(maintainers "3L0C")

(implicit_transitive_deps false)

(package
 (name oxbow)
 (synopsis "Dynamic window manager for the river Wayland compositor")
 (description
  "oxbow is a window manager for River 0.4.6+, written in OCaml.\nIt manages windows with built-in dynamic layouts.\n\nThe package installs two executables:\n\n- oxbow: the window manager\n- oxctl: a CLI client for commands, queries, and event subscriptions\n\nConfiguration is an init script of oxctl commands.")
 (depends
  (ocaml
   (>= 5.4))
  (dune-build-info
   (>= 3.22))
  (cmdliner
   (>= 2.1))
  (cstruct
   (and
    (>= 6.2)
    :with-test))
  (eio
   (>= 1.3))
  (eio_main
   (>= 1.2))
  (eio_posix
   (>= 1.3))
  (fmt
   (>= 0.11))
  (landmarks
   (>= 1.7))
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
