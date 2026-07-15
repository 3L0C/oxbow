type t =
  | Okay
  | Usage
  | Dataerr
  | Noinput
  | Nouser
  | Nohost
  | Unavailable
  | Software
  | Oserr
  | Osfile
  | Cantcreat
  | Ioerr
  | Tempfail
  | Protocol
  | Noperm
  | Config

let to_int = function
  | Okay -> 0
  | Usage -> 64
  | Dataerr -> 65
  | Noinput -> 66
  | Nouser -> 67
  | Nohost -> 68
  | Unavailable -> 69
  | Software -> 70
  | Oserr -> 71
  | Osfile -> 72
  | Cantcreat -> 73
  | Ioerr -> 74
  | Tempfail -> 75
  | Protocol -> 76
  | Noperm -> 77
  | Config -> 78
;;

let ok = to_int Okay
let ok_info = "on success"
let usage = to_int Usage
let usage_info = "on command line usage error"
let dataerr = to_int Dataerr
let dataerr_info = "on data format error"
let noinput = to_int Noinput
let noinput_info = "on failure to open input"
let nouser = to_int Nouser
let nouser_info = "on unknown addressee"
let nohost = to_int Nohost
let nohost_info = "on unknown host name"
let unavailable = to_int Unavailable
let unavailable_info = "on unavailable service"
let software = to_int Software
let software_info = "on internal software error"
let oserr = to_int Oserr
let oserr_info = "on system error (e.g., can't fork)"
let osfile = to_int Osfile
let osfile_info = "on critical OS file missing"
let cantcreat = to_int Cantcreat
let cantcreat_info = "on failure to create (user) output file"
let ioerr = to_int Ioerr
let ioerr_info = "on input/output error"
let tempfail = to_int Tempfail
let tempfail_info = "on temporary failure; user is invited to retry"
let protocol = to_int Protocol
let protocol_info = "on remote error in protocol"
let noperm = to_int Noperm
let noperm_info = "on permision denied"
let config = to_int Config
let config_info = "on configuration error"

let exits =
  let open Cmdliner in
  List.fold_left
    (fun acc (code, doc) -> Cmd.Exit.info code ~doc :: acc)
    []
    [ ok, ok_info
    ; usage, usage_info
    ; dataerr, dataerr_info
    ; noinput, noinput_info
    ; nouser, nouser_info
    ; nohost, nohost_info
    ; unavailable, unavailable_info
    ; software, software_info
    ; oserr, oserr_info
    ; osfile, osfile_info
    ; cantcreat, cantcreat_info
    ; ioerr, ioerr_info
    ; tempfail, tempfail_info
    ; protocol, protocol_info
    ; noperm, noperm_info
    ; config, config_info
    ]
;;
