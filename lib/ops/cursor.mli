(** [apply seat ~name ~size] applies the cursor theme [name]/[size] to [seat].

    {b Effects:} sends River request *)
val apply : Ocdwm_state.Seat.t -> name:string -> size:int32 -> unit

(** [set_theme wm seat name size] records [name]/[size] in the user
    configuration, and calls [set_xcursor_theme] on [seat].

    {b Effects:} mutates WM state; sends River request *)
val set_theme : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> string -> int32 -> unit
