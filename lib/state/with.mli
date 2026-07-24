(** [focused_output seat f] applies [f] to [seat]'s focused output. Is
    [Error msg] if [seat] has no output. *)
val focused_output
  :  Types.Seat.t
  -> (Output.t -> ('a, string) result)
  -> ('a, string) result

(** [focused_window seat f] applies [f] to [seat]'s focused output and window.
    Is [Error msg] if [seat] has no output or focused window. *)
val focused_window
  :  Types.Seat.t
  -> (Output.t -> Types.Window.t -> ('a, string) result)
  -> ('a, string) result

(** [output window f] applies [f] to [window]'s outupt. Is [Error msg] if
    [window] has no output. *)
val output : Types.Window.t -> (Output.t -> ('a, string) result) -> ('a, string) result
