(** [set_repeat wm ~rate ~delay] stores [rate]/[delay] in [wm.config]
    and calls [set_repeat_info] on every entry in [wm.input_devices]
    whose [kind] is [Some Keyboard].

    {b Effects:} mutates WM state; sends River request *)
val set_repeat : Types.Window_manager.t -> rate:int -> delay:int -> unit

(** [set_layout_file wm ~path] opens [path] and asks the compositor to
    compile it into a keymap, applied to every xkb keyboard once the
    [success] event arrives. Is [Error msg] on synchronous failure,
    [Ok ()] otherwise.

    {b Effects:} mutates WM state; sends River request *)
val set_layout_file : Types.Window_manager.t -> path:string -> (unit, string) result
