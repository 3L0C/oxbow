(** [manage wm proxy] runs on manage phase; behavior branches
    on [wm]'s lifecycle.

    {b Effects:} mutates WM state; sends River request *)
val manage : Ocdwm_state.Wm.t -> River.Obj.Window_management.Wm.t -> unit

(** [render wm proxy] runs one render phase.

    {b Effects:} sends River request *)
val render : Ocdwm_state.Wm.t -> River.Obj.Window_management.Wm.t -> unit
