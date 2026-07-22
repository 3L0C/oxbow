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

(** [window_missing_output] is the standard error message used when an operation
    is performed on a window that is not attached to any output. *)
val window_missing_output : string

(** [tag_set_is_empty] is the standard error message used when the given tag set
    is empty. *)
val tag_set_is_empty : string

(** [not_scrolling] is the standard error message used when an operation is
    performed on an output that is not in the [Scrolling] layout. *)
val not_scrolling : string
