(** [ok] indicates successful termination *)
let ok () = Stdlib.exit 0

(** [usage] indicates command line usage error *)
let usage () = Stdlib.exit 64

(** [dataerr] indicates data format error *)
let dataerr () = Stdlib.exit 65

(** [noinput] indicates the programs couldnot open input *)
let noinput () = Stdlib.exit 66

(** [nouser] indecates addressee unknown *)
let nouser () = Stdlib.exit 67

(** [nohost] indicates host name unknown *)
let nohost () = Stdlib.exit 68

(** [unavailable] indicates service unavailable *)
let unavailable () = Stdlib.exit 69

(** [software] indicates an internal software error *)
let software () = Stdlib.exit 70

(** [oserr] indicates system error (e.g., can't fork) *)
let oserr () = Stdlib.exit 71

(** [osfile] indicates critical OS file missing *)
let osfile () = Stdlib.exit 72

(** [cantcreat] indicates can't create (user) output file *)
let cantcreat () = Stdlib.exit 73

(** [ioerr] indicates input/output error *)
let ioerr () = Stdlib.exit 74

(** [tempfail] indicates temp failure; user is invited to retry *)
let tempfail () = Stdlib.exit 75

(** [protocol] indicates a remote error in protocol *)
let protocol () = Stdlib.exit 76

(** [noperm] indicates permission denied *)
let noperm () = Stdlib.exit 77

(** [config] indicates a configuration error *)
let config () = Stdlib.exit 78
