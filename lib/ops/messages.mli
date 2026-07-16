(** [seat_missing_output] is the standard error message used when an operation
    is performed on a seat with no output. *)
val seat_missing_output : string

(** [no_focused_window] is the standard error message used when an operation is
    performed on a seat with no focused window. *)
val no_focused_window : string

(** [window_is_fullscreen] is the standard error message used when an invalid
    operation is performed on a fullscreen window. *)
val window_is_fullscreen : string

(** [no_other_output] is the standard error message used when an operation is
    performed on an output that doesn't exist. *)
val no_other_output : string
