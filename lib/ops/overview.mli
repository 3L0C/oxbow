(** [arrange wm output] grids every window on [output] (all tags, floating and
    maximized included) into a vertical grid over the usable area, gaps and
    borders applied. The grid has at most 3 columns. Each row has half the
    height of the usable area. Rows that do not fit sit below the usable area.
    The viewport follows the focused window with the Visible scroll rule. Each
    window clips to its cell and to the usable area *)
val arrange : Ocdwm_state.Wm.t -> Ocdwm_state.Output.t -> unit
