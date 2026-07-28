(** [arrange wm output] grids every window on [output] (all tags, floating and
    maximized included) into a near-square grid over the usable area, gaps and
    borders applied. *)
val arrange : Ocdwm_state.Wm.t -> Ocdwm_state.Output.t -> unit
