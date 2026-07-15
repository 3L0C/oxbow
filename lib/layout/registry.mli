type t

(** [create ()] is a registry seeded with the builtin layouts ([Tile],
    [Monocle], [Floating]), in that order. *)
val create : unit -> t

(** [default_layout_entry registry] is the first registered entry.

    @raise Failure when [registry] is empty. *)
val default_layout_entry : t -> Entry.t

(** [default_layout_meta registry] is [default_layout_entry]'s metadata. *)
val default_layout_meta : t -> Entry.Meta.t

(** [register registry entry] appends [entry]; an existing entry with the same
    name is replaced, with a warning. *)
val register : t -> Entry.t -> unit

(** [find registry name] is the entry registered as [name], if any. *)
val find : t -> string -> Entry.t option

(** [cycle registry name dir] is the registered neighbor of [name] in direction
    [dir], wrapping at the ends (a lone entry cycles to itself); [None] when
    [name] is not registered. *)
val cycle : t -> string -> Ocdwm_core.Direction.Logical.t -> (string * Entry.t) option
