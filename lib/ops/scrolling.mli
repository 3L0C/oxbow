(** [arrange wm output] arranges [output]'s tiled windows as a horizontal strip
    of full-height columns. Windows keep true strip positions; off-viewport
    visibility is handled by [Window.is_rendered] and clip state by
    [Window.sync]. *)
val arrange : Oxbow_state.Wm.t -> Oxbow_state.Output.t -> unit
