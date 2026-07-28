type t =
  { mods : int32
  ; key : Ocdwm_state.Types.Key.t
  }

(** [install_defaults wm seat] installs system default keybinds to [seat].

    {b Effects:} mutates WM state *)
val install_defaults : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> unit

(** [parse_modifiers s] maps recognized modifier strings to Wayland [int32]
    representations. Recognized strings include:
    - {b Shift}
    - {b Control}
    - {b Mod1}|{b Alt}
    - {b Mod3}
    - {b Mod4}|{b Super}|{b Logo}: i.e., the windows key
    - {b Mod5}
    - {b None}

    Any other string returns [Error "unrecognized"]. *)
val parse_modifiers : string -> (int32, string) result

(** [parse_keysym name] is the keysym represented by [name]. See:
    - https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
    - https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon.h
      (check the comments for [xkb_keysym_from_name] and [xkb_keysym_t].)

    TL;DR to get the keysym [XKB_KEY_space] use everything after [XKB_KEY_]:
    - {b space}: [XKB_KEY_space]
    - {b plus}: [XKB_KEY_plus] *)
val parse_keysym : string -> (Xkbcommon.Keysym.t, string) result

(** [parse_button s] maps recognized button strings to [Pointer_button.t]
    representations. Recognized strings include:
    - {b Btn_0}
    - {b Btn_1}
    - {b Btn_2}
    - {b Btn_3}
    - {b Btn_4}
    - {b Btn_5}
    - {b Btn_6}
    - {b Btn_7}
    - {b Btn_8}
    - {b Btn_9}
    - {b Btn_left}
    - {b Btn_right}
    - {b Btn_middle}
    - {b Btn_side}
    - {b Btn_extra}
    - {b Btn_forward}
    - {b Btn_back}
    - {b Btn_task}

    Any other string returns [Error "unrecognized"]. *)
val parse_button : string -> (Ocdwm_core.Pointer_button.t, string) result

(** [parse s] is the [{mods; key}] represented by s. [s] is a string of zero or
    more modifiers, and a keysym or button combined with '+':
    - {b Super+space}
    - {b Super+Control+Btn_left}
    - {b plus}|{b Btn_middle}

    See [parse_modifiers], [parse_keysym], and [parse_button] for more details. *)
val parse : string -> (t, string) result

(** [format_modifiers mods] is the modifier names set in [mods], in the
    canonical order Super, Alt, Control, Shift, Mod3, Mod5. Empty when [mods] is
    [0l]. *)
val format_modifiers : int32 -> string list

(** [format_keybind mods key] is the keybind string for [mods] and [key]: the
    inverse of [parse]. [parse (format_keybind mods key)] is [Ok { mods; key }]. *)
val format_keybind : int32 -> Ocdwm_state.Types.Key.t -> string

(** [list wm seat ~all] is the JSON keybinding listing for [seat]; its name,
    stored mode, and bindings grouped by declared mode, or for every seat in
    [wm] when [all] is [true]. *)
val list : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> all:bool -> Yojson.Safe.t

(** [handle wm seat keymap] applies the Bind/Unbind [keymap].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Keymap.t
  -> (Yojson.Safe.t option, string) result
