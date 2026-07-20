(** [set_mfact seat delta] adjusts the master-area fraction on the first
    selected tag of [seat]'s output.

    {b Effects:} mutates WM state *)
val set_mfact
  :  Ocdwm_state.Seat.t
  -> float Ocdwm_core.Delta.t
  -> (Yojson.Safe.t option, string) result

(** [set_nmaster seat delta] adjusts the master window count on the first
    selected tag of [seat]'s output.

    {b Effects:} mutates WM state *)
val set_nmaster
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_inner seat delta] adjusts the inner gaps on the first selected tag
    of [seat]'s output.

    {b Effects:} mutates WM state *)
val set_gaps_inner
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_outer seat delta] adjusts the outer gaps on the first selected tag
    of [seat]'s output.

    {b Effects:} mutates WM state *)
val set_gaps_outer
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> (Yojson.Safe.t option, string) result

(** [set_stack seat kind] sets the stack arrangement on the first selected tag
    of [seat]'s output.

    {b Effects:} mutates WM state *)
val set_stack
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Stack_kind.t
  -> (Yojson.Safe.t option, string) result

(** [set_dir seat dir] sets the stack direction on the first selected tag of
    [seat]'s output.

    {b Effects:} mutates WM state *)
val set_dir
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> (Yojson.Safe.t option, string) result

(** [retile ctx output] arranges [output]'s managed windows.

    {b Effects:} mutates WM state; sends River request *)
val retile : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Output.t -> unit
