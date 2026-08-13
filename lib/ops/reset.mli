(** [config wm ~all] restores the compiled-in configuration defaults. [all]
    also removes rules, keybinds, modes, and labels.

    {b Effects:} mutates WM state *)
val config : Oxbow_state.Types.Wm.t -> all:bool -> (Yojson.Safe.t option, string) result
