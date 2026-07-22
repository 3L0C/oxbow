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

(** [set_scroll_policy seat policy] sets the scrolling policy arrangement on the
    first selected tag of [seat]'s output.

    {b Effects:} mutates WM state *)
val set_scroll_policy
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Scroll_policy.t
  -> (Yojson.Safe.t option, string) result

(** [set_dir seat dir] sets the stack direction on the first selected tag of
    [seat]'s output.

    {b Effects:} mutates WM state *)
val set_dir
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> (Yojson.Safe.t option, string) result

(** [enter_overview ctx output] handles the transition to the [Overview]
    arrangement. No-op when [output] is already in [Overview].

    {b Effects:} mutates WM state *)
val enter_overview
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Output.t
  -> unit

(** [exit_overview ctx output] handles the transition from [Overview] to any
    other arrangement. No-op when [output] is not in [Overview].

    {b Effects:} mutates WM state *)
val exit_overview
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Output.t
  -> unit

(** [toggle_overview ctx seat] enters or leaves overview on [seat]'s output.  Entering
    exits fullscreen. Leaving views exactly the focused window's tags and
    restores floating and maximized geometry.

    {b Effects:} mutates WM state; sends River requests *)
val toggle_overview
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> ('a option, string) result

(** [set_arrangement ctx seat arrangement] sets [seat]'s focused output
    arrangement to [arrangement]. No-op when already set to [arrangement].

    {b Effects:} mutates WM state *)
val set_arrangement
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Arrangement.t
  -> (Yojson.Safe.t option, string) result

(** [retile ctx output] arranges [output]'s managed windows.

    {b Effects:} mutates WM state; sends River request *)
val retile : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Output.t -> unit
