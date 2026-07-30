(** [set_mfact seat delta ~global] adjusts the master-area fraction on the first
    selected tag of [seat]'s output. When [global] is [true], the change applies
    to every tag.

    {b Effects:} mutates WM state *)
val set_mfact
  :  Ocdwm_state.Seat.t
  -> float Ocdwm_core.Delta.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [set_nmaster seat delta ~global] adjusts the master window count on the
    first selected tag of [seat]'s output. When [global] is [true], the change
    applies to every tag.

    {b Effects:} mutates WM state *)
val set_nmaster
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_inner seat delta ~global] adjusts the inner gaps on the first
    selected tag of [seat]'s output. When [global] is [true], the change applies
    to every tag.

    {b Effects:} mutates WM state *)
val set_gaps_inner
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_outer seat delta ~global] adjusts the outer gaps on the first
    selected tag of [seat]'s output. When [global] is [true], the change applies
    to every tag.

    {b Effects:} mutates WM state *)
val set_gaps_outer
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_overview seat delta] adjusts the overview gaps on [seat]'s focused
    output.

    {b Effects:} mutates WM state *)
val set_gaps_overview
  :  Ocdwm_state.Seat.t
  -> int Ocdwm_core.Delta.t
  -> (Yojson.Safe.t option, string) result

(** [set_scroll_policy wm seat policy ~global] sets the scrolling layout policy
    on [seat]'s output. Applied to all tags when [global] is [true]. Applies to
    all tags on all outputs if [global] is [true]. Applied to the first selected
    tag when [false].

    {b Effects:} mutates WM state *)
val set_scroll_policy
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Scroll_policy.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [set_default_width wm seat delta ~global] sets the default column width
    according to [delta] on [seat]'s focused output. Applies to all tags on all
    outputs if [global] is [true]. Applied to the first selected tag when
    [false].

    {b Effects:} mutates WM state *)
val set_default_width
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> float Ocdwm_core.Delta.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [set_orientation seat dir ~global] sets the stack direction on [seat]'s
    output. Applied to all tags if [global] is [true]. Applied to the first
    selected tag when [false].

    {b Effects:} mutates WM state *)
val set_orientation
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [enter_overview wm output] handles the transition to the [Overview] layout.
    No-op when [output] is already in [Overview].

    {b Effects:} mutates WM state *)
val enter_overview : Ocdwm_state.Wm.t -> Ocdwm_state.Output.t -> unit

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

(** [set_layout seat layout ~global] sets the layout on [seat]'s focused output.
    Applied to all tags when [global] is [true]. Applied to the first selected
    tag when [false]. Saves float geometry for tiled windows when the switch
    enters or leaves the [Floating] layout.

    {b Effects:} mutates WM state *)
val set_layout
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Layout.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [select_scheme seat scheme ~global] sets [seat]'s focused output to
    [scheme]. Applied to all tags when [global] is [true]. Applied to the first
    selected tag when [false]. Is [Error msg] when [seat] has no output.

    {b Effects:} mutates WM state *)
val select_scheme
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Scheme.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [cycle_scheme seat dir] sets the current scheme's registered neighbor in
    [dir] on the first selected tag of [seat]'s output; tiled windows leaving
    the [floating] layout remember their geometry. Is [Error msg] when [seat]
    has no output.

    {b Effects:} mutates WM state *)
val cycle_scheme
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [cycle_layout seat dir] sets the current layout's registered neighbor in
    [dir] on the first selected tag of [seat]'s output. Is [Error msg] when
    [seat] has no output.

    {b Effects:} mutates WM state *)
val cycle_layout
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [retile wm output] arranges [output]'s managed windows.

    {b Effects:} mutates WM state *)
val retile : Ocdwm_state.Wm.t -> Ocdwm_state.Output.t -> unit
