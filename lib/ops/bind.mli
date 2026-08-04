(** [install_defaults wm seat] installs system default keybinds to [seat].

    {b Effects:} mutates WM state *)
val install_defaults : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> unit

(** [parse_modifier s] maps recognized modifier strings to Wayland [int32]
    representations. Recognized strings include:
    - {b Shift}
    - {b Control}
    - {b Mod1}|{b Alt}
    - {b Mod3}
    - {b Mod4}|{b Super}|{b Logo}: i.e., the windows key
    - {b Mod5}
    - {b None}

    Any other string returns [Error "unrecognized"]. *)
val parse_modifier : string -> (int32, string) result

(** [list wm seat ~all] is the JSON keybinding listing for [seat]; its name,
    stored mode, and bindings grouped by declared mode, or for every seat in
    [wm] when [all] is [true]. *)
val list : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> all:bool -> Yojson.Safe.t

(** [handle wm seat keymap] applies the Bind/Unbind [keymap].

    {b Effects:} mutates WM state *)
val handle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_ipc.Keymap.t
  -> (Yojson.Safe.t option, string) result
