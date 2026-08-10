(** [set_tiling_scheme wm seat scheme scope] sets the tiling layout scheme on
    the output according to [scope].

    {b Effects:} mutates WM state *)
val set_tiling_scheme
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Scheme.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_mfact wm seat delta scope] adjusts the master-area fraction on output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_mfact
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> float Oxbow_core.Delta.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_nmaster wm seat delta scope] adjusts the master window count on output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_nmaster
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> int Oxbow_core.Delta.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_inner wm seat delta scope] adjusts the inner gaps on output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_gaps_inner
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> int Oxbow_core.Delta.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_outer wm seat delta scope] adjusts the outer gaps on the output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_gaps_outer
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> int Oxbow_core.Delta.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_scrolling_alignment wm seat align scope] sets the scrolling layout align
    on the output according to [scope].

    {b Effects:} mutates WM state *)
val set_scrolling_alignment
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Align.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_gaps_overview wm seat delta scope] adjusts the overview gaps on the
    output according to [scope].

    {b Effects:} mutates WM state *)
val set_gaps_overview
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> int Oxbow_core.Delta.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_default_width wm seat delta scope] sets the default column width on the
    output according to [scope].

    {b Effects:} mutates WM state *)
val set_default_width
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> float Oxbow_core.Delta.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [set_orientation wm seat dir scope] sets the stack direction on the output
    according to [scope].

    {b Effects:} mutates WM state *)
val set_orientation
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Spatial.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [exit_overview output] handles the transition from [Overview] to any other
    layout. No-op when [output] is not in [Overview].

    {b Effects:} mutates WM state *)
val exit_overview : Oxbow_state.Output.t -> unit

(** [toggle_overview wm seat] enters or leaves overview on [seat]'s output.  Entering
    exits fullscreen. Leaving views exactly the focused window's tags and
    restores floating and maximized geometry.

    {b Effects:} mutates WM states *)
val toggle_overview : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> ('a option, string) result

(** [overview_cycle wm seat dir ~until_release] enters overview on [seat]'s
    output when it is closed, then moves the overview head one step through the
    focus stack in [dir]. When [until_release] holds a modifier string, arms the
    seat's modifier watch with the parsed set.

    {b Effects:} mutates WM state, may schedule *)
val cycle_overview
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> until_release:string option
  -> (Yojson.Safe.t option, string) result

(** [set_layout wm seat layout scope] sets the layout on the output according to
    [scope].

    {b Effects:} mutates WM state *)
val set_layout
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Layout.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [select_tiling_scheme wm seat scheme scope] switches to the [Tiling] layout
    with the scheme on the output applied to [scope].

    {b Effects:} mutates WM state *)
val select_tiling_scheme
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Scheme.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [select_scrolling_alignment wm seat align scope] switches to the [Scrolling]
    layout with the align on the output applied to [scope].

    {b Effects:} mutates WM state *)
val select_scrolling_alignment
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Align.t
  -> Oxbow_core.Scope.t
  -> (Yojson.Safe.t option, string) result

(** [cycle_scheme wm seat dir] sets the current scheme's registered neighbor in
    [dir] on the first selected tag of [seat]'s output; tiled windows leaving
    the [floating] layout remember their geometry. Is [Error msg] when [seat]
    has no output.

    {b Effects:} mutates WM state *)
val cycle_scheme
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [cycle_layout wm seat dir] sets the current layout's registered neighbor in
    [dir] on the first selected tag of [seat]'s output. Is [Error msg] when
    [seat] has no output.

    {b Effects:} mutates WM state *)
val cycle_layout
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [retile wm output] arranges [output]'s managed windows.

    {b Effects:} mutates WM state *)
val retile : Oxbow_state.Wm.t -> Oxbow_state.Output.t -> unit
