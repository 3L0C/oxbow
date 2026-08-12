(** A keybind mode. A value exists only for a declared mode:
    [resolve] and [declare] are the only constructors. *)
type t

(** [normal] is the built-in mode every binding belongs to by default. *)
val normal : t

(** [locked] is the built-in mode in effect while the session is locked. *)
val locked : t

val equal : t -> t -> bool

(** [to_string mode] is the name of [mode]. *)
val to_string : t -> string

(** [resolve name ~declared] is the mode in [declared] named [name], or
    [Error msg] when no declared mode has [name]. *)
val resolve : string -> declared:t list -> (t, string) result

(** [declare name ~declared] is a new mode named [name], or [Error msg] when
    [declared] already has a mode with [name]. *)
val declare : string -> declared:t list -> (t, string) result
