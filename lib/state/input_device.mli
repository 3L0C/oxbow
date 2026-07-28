include module type of Types.Input_device

(** [role_to_string role] is the string representation of [role]. *)
val role_to_string : Role.t -> string

(** [set_keyboard wm entry xkb] sets [entry]'s xkb attribute to [xkb] if [entry] is a
    keyboard. Logs a warning if [entry] is not a keyboard. Sends a River request
    to set the user's configured keymap.

    {b Effects:} mutates WM state; sends River request *)
val set_keyboard : Types.Wm.t -> t -> Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [clear_entry entry proxy] clears [entry] if it is holding [proxy].

    {b Effects:} mutates WM state *)
val clear_entry : t -> Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [remove_entry entry] deletes [entry]'s associated Wayland objects. Is a
    no-op if [entry] was already removed.

    {b Effects:} mutates WM state; sends River request *)
val remove_entry : t -> unit

(** [to_keyboard entry] is [Some keyboard] if [entry] is a keyboard with a
    defined proxy, otherwise [None]. *)
val to_keyboard : t -> Wire.Obj.Xkb.Config.Keyboard.t option

(** [id device] is the protocol object id of [device]. The bridge uses it as a
    map key. *)
val id : Wire.Obj.Input.Management.Device.t -> int32
