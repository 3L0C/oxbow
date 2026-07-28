(** [apply seat ~name ~size] applies the cursor theme [name]/[size] to [seat]. *)
val apply : Ocdwm_state.Seat.t -> name:string -> size:int32 -> unit

(** [set_theme wm seat name size] records [name]/[size] in the user
    configuration, and calls [set_xcursor_theme] on [seat].

    {b Effects:} mutates WM state *)
val set_theme : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> string -> int32 -> unit

(** [handle wm seat cmd] handles the cursor command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Input.Cursor.t
  -> (Yojson.Safe.t option, string) result
