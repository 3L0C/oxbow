(** [set_mfact wm seat delta scope] adjusts the master-area fraction on output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_mfact
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> float Ocdwm_core.Delta.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_nmaster wm seat delta scope] adjusts the master window count on output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_nmaster
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_inner wm seat delta scope] adjusts the inner gaps on output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_gaps_inner
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_outer wm seat delta scope] adjusts the outer gaps on the output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_gaps_outer
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_overview wm seat delta scope] adjusts the overview gaps on the
    output according to [scope].

    {b Effects:} mutates WM state *)
val set_gaps_overview
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_scroll_policy wm seat policy scope] sets the scrolling layout policy on
    the output according to [scope].

    {b Effects:} mutates WM state *)
val set_scroll_policy
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Scroll_policy.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_default_width wm seat delta scope] sets the default column width on the
    output according to [scope].

    {b Effects:} mutates WM state *)
val set_default_width
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> float Ocdwm_core.Delta.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_orientation wm seat dir scope] sets the stack direction on the output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_orientation
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [exit_overview output] handles the transition from [Overview] to any other
    layout. No-op when [output] is not in [Overview].

    {b Effects:} mutates WM state *)
val exit_overview : Ocdwm_state.Output.t -> unit

(** [toggle_overview wm seat] enters or leaves overview on [seat]'s output.  Entering
    exits fullscreen. Leaving views exactly the focused window's tags and
    restores floating and maximized geometry.

    {b Effects:} mutates WM states *)
val toggle_overview : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> ('a option, string) result

(** [overview_cycle wm seat dir ~until_release] enters overview on [seat]'s
    output when it is closed, then moves the overview head one step through the
    focus stack in [dir]. When [until_release] holds a modifier string, arms the
    seat's modifier watch with the parsed set.

    {b Effects:} mutates WM state, may schedule *)
val cycle_overview
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> until_release:string option
  -> (Yojson.Safe.t option, string) result

(** [set_layout wm seat layout scope] sets the layout on the output according to
    [scope].

    {b Effects:} mutates WM state *)
val set_layout
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Layout.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [select_scheme wm seat scheme scope] sets the scheme on the output according
    to [scope].

    {b Effects:} mutates WM state *)
val select_scheme
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Scheme.t
  -> Ocdwm_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [cycle_scheme wm seat dir] sets the current scheme's registered neighbor in
    [dir] on the first selected tag of [seat]'s output; tiled windows leaving
    the [floating] layout remember their geometry. Is [Error msg] when [seat]
    has no output.

    {b Effects:} mutates WM state *)
val cycle_scheme
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [cycle_layout wm seat dir] sets the current layout's registered neighbor in
    [dir] on the first selected tag of [seat]'s output. Is [Error msg] when
    [seat] has no output.

    {b Effects:} mutates WM state *)
val cycle_layout
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [retile wm output] arranges [output]'s managed windows.

    {b Effects:} mutates WM state *)
val retile : Ocdwm_state.Wm.t -> Ocdwm_state.Output.t -> unit
