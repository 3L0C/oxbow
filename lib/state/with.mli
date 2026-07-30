(** [focused_output seat f] applies [f] to [seat]'s focused output. Is
    [Error msg] if [seat] has no output. *)
val focused_output
  :  Types.Seat.t
  -> (Types.Output.t -> ('a, string) result)
  -> ('a, string) result

(** [focused_output_log ?out seat f] applies [f] to [seat]'s focused output.
    Logs any [Error msg] according to [out] if [seat] has no output. If [out]
    is not present, [Error msg] will be logged to [`Debug]. *)
val focused_output_log
  :  ?out:[< `Debug | `Info | `Error | `Warn ]
  -> Types.Seat.t
  -> (Types.Output.t -> unit)
  -> unit

(** [named_output ~name wm f] applies [f] to the first output matching [name].
    Is [Error msg] if [wm] contains no output matching [name]. *)
val named_output
  :  name:string
  -> Types.Wm.t
  -> (Types.Output.t -> ('a, string) result)
  -> ('a, string) result

(** [named_output_log ?out ~name wm f] applies [f] to the first output matching
    [name]. Logs any [Error msg] according to [out] if [wm] contains no output
    matching [name]. If [out] is not present, [Error msg] will be logged to
    [`Debug]. *)
val named_output_log
  :  ?out:[ `Debug | `Info | `Error | `Warn ]
  -> name:string
  -> Types.Wm.t
  -> (Types.Output.t -> unit)
  -> unit

(** [focused_window seat f] applies [f] to [seat]'s focused output and window.
    Is [Error msg] if [seat] has no output or focused window. *)
val focused_window
  :  Types.Seat.t
  -> (Types.Output.t -> Types.Window.t -> ('a, string) result)
  -> ('a, string) result

(** [focused_window_log ?out seat f] applies [f] to [seat]'s focused output and
    window.Logs any [Error msg] according to [out] if [seat] has no output or
    window. If [out] is not present, [Error msg] will be logged to [`Debug]. *)
val focused_window_log
  :  ?out:[< `Debug | `Info | `Error | `Warn ]
  -> Types.Seat.t
  -> (Types.Output.t -> Types.Window.t -> unit)
  -> unit

(** [output window f] applies [f] to [window]'s outupt. Is [Error msg] if
    [window] has no output. *)
val output
  :  Types.Window.t
  -> (Types.Output.t -> ('a, string) result)
  -> ('a, string) result

(** [output_log ?out window f] applies [f] to [window]'s output.  Logs any
    [Error msg] according to [out] if [window] has no output. If [out] is not
    present, [Error msg] will be logged to [`Debug]. *)
val output_log
  :  ?out:[< `Debug | `Info | `Error | `Warn ]
  -> Types.Window.t
  -> (Types.Output.t -> unit)
  -> unit
