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

(** [ok] indicates successful termination *)
val ok : int

(** [usage] indicates command line usage error *)
val usage : int

(** [dataerr] indicates data format error *)
val dataerr : int

(** [noinput] indicates the programs could not open input *)
val noinput : int

(** [nouser] indicates addressee unknown *)
val nouser : int

(** [nohost] indicates host name unknown *)
val nohost : int

(** [unavailable] indicates service unavailable *)
val unavailable : int

(** [software] indicates an internal software error *)
val software : int

(** [oserr] indicates system error (e.g., can't fork) *)
val oserr : int

(** [osfile] indicates critical OS file missing *)
val osfile : int

(** [cantcreat] indicates can't create (user) output file *)
val cantcreat : int

(** [ioerr] indicates input/output error *)
val ioerr : int

(** [tempfail] indicates temp failure; user is invited to retry *)
val tempfail : int

(** [protocol] indicates a remote error in protocol *)
val protocol : int

(** [noperm] indicates permission denied *)
val noperm : int

(** [config] indicates a configuration error *)
val config : int

(** [exits] is the exit information for [Cmdliner] covering every code. *)
val exits : Cmdliner.Cmd.Exit.info list
