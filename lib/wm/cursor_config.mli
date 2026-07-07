(** [apply seat ~name ~size] applies the cursor theme [name]/[size] to
    [seat].

    {b Effects:} sends River request *)
val apply : Types.Seat.t -> name:string -> size:int32 -> unit

(** [set_theme wm seat ~name ~size] records [name]/[size] in [wm.config] and
    calls [set_xcursor_theme] on [seat].

    {b Effects:} mutates WM state; sends River request *)
val set_theme
  :  Types.Window_manager.t
  -> Types.Seat.t
  -> name:string
  -> size:int32
  -> unit
