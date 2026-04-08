(* successful termination *)
let ok () = Stdlib.exit 0

(* command line usage error *)
let usage () = Stdlib.exit 64

(* data format error *)
let dataerr () = Stdlib.exit 65

(* cannot open input *)
let noinput () = Stdlib.exit 66

(* addressee unknown *)
let nouser () = Stdlib.exit 67

(* host name unknown *)
let nohost () = Stdlib.exit 68

(* service unavailable *)
let unavailable () = Stdlib.exit 69

(* internal software error *)
let software () = Stdlib.exit 70

(* system error (e.g., can't fork) *)
let oserr () = Stdlib.exit 71

(* critical OS file missing *)
let osfile () = Stdlib.exit 72

(* can't create (user) output file *)
let cantcreat () = Stdlib.exit 73

(* input/output error *)
let ioerr () = Stdlib.exit 74

(* temp failure; user is invited to retry *)
let tempfail () = Stdlib.exit 75

(* remote error in protocol *)
let protocol () = Stdlib.exit 76

(* permission denied *)
let noperm () = Stdlib.exit 77

(* configuration error *)
let config () = Stdlib.exit 78
