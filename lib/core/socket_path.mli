(** [resolve ?override ()] is [override] when given, else [$OXBOW_SOCKET] when
    set, else ["$XDG_RUNTIME_DIR/oxbow-$WAYLAND_DISPLAY.sock"], falling back to
    [$HOME] and ["wayland-0"] when the variables are unset. *)
val resolve : ?override:string -> unit -> string
