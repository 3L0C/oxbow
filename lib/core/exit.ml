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

(** [ok] indicates successful termination *)
let ok = to_int Okay

let ok_info = "on success"

(** [usage] indicates command line usage error *)
let usage = to_int Usage

let usage_info = "on command line usage error"

(** [dataerr] indicates data format error *)
let dataerr = to_int Dataerr

let dataerr_info = "on data format error"

(** [noinput] indicates the programs could not open input *)
let noinput = to_int Noinput

let noinput_info = "on failure to open input"

(** [nouser] indecates addressee unknown *)
let nouser = to_int Nouser

let nouser_info = "on unknown addressee"

(** [nohost] indicates host name unknown *)
let nohost = to_int Nohost

let nohost_info = "on unknown host name"

(** [unavailable] indicates service unavailable *)
let unavailable = to_int Unavailable

let unavailable_info = "on unavailable service"

(** [software] indicates an internal software error *)
let software = to_int Software

let software_info = "on internal software error"

(** [oserr] indicates system error (e.g., can't fork) *)
let oserr = to_int Oserr

let oserr_info = "on system error (e.g., can't fork)"

(** [osfile] indicates critical OS file missing *)
let osfile = to_int Osfile

let osfile_info = "on critical OS file missing"

(** [cantcreat] indicates can't create (user) output file *)
let cantcreat = to_int Cantcreat

let cantcreat_info = "on failure to create (user) output file"

(** [ioerr] indicates input/output error *)
let ioerr = to_int Ioerr

let ioerr_info = "on input/output error"

(** [tempfail] indicates temp failure; user is invited to retry *)
let tempfail = to_int Tempfail

let tempfail_info = "on temporary failure; user is invited to retry"

(** [protocol] indicates a remote error in protocol *)
let protocol = to_int Protocol

let protocol_info = "on remote error in protocol"

(** [noperm] indicates permission denied *)
let noperm = to_int Noperm

let noperm_info = "on permision denied"

(** [config] indicates a configuration error *)
let config = to_int Config

let config_info = "on configuration error"

(** [exits] is a list of exit info for [Cmdliner] *)
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
