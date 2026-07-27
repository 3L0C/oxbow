include module type of Types.Input_device

(** [role_to_string role] is the string representation of [role]. *)
val role_to_string : Role.t -> string

(** [set_xkb wm entry xkb] sets [entry]'s xkb attribute to [xkb] if [entry] is a
    keyboard. Logs a warning if [entry] is not a keyboard. Sends a River request
    to set the user's configured keymap.

    {b Effects:} mutates WM state; sends River request *)
val set_xkb : Types.Wm.t -> t -> River.Obj.Xkb.Config.Keyboard.t -> unit

(** [clear_xkb entry xkb] clears [entry]'s xkb attribute if it is holding [xkb].

    {b Effects:} mutates WM state *)
val clear_xkb : t -> River.Obj.Xkb.Config.Keyboard.t -> unit

(** [remove_entry entry] deletes [entry]'s associated Wayland objects. Is a
    no-op if [entry] was already removed.

    {b Effects:} mutates WM state; sends River request *)
val remove_entry : t -> unit

(** [to_xkb entry] is [Some xkb] if [entry] is a keyboard with an xkb device
    defined, otherwise [None]. *)
val to_xkb : t -> River.Obj.Xkb.Config.Keyboard.t option

(** [id device] is the protocol object id of [device]. The bridge uses it as a
    map key. *)
val id : River.Obj.Input.Management.Device.t -> int32
