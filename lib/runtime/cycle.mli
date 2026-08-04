(** [manage wm proxy] runs on manage phase; behavior branches
    on [wm]'s lifecycle.

    {b Effects:} mutates WM state *)
val manage : Oxbow_state.Wm.t -> River.Obj.Window_management.Wm.t -> unit

(** [render wm proxy] runs one render phase. *)
val render : Oxbow_state.Wm.t -> River.Obj.Window_management.Wm.t -> unit
