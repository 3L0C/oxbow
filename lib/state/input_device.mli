include module type of Types.Input_device

(** [role_to_string role] is the string representation of [role]. *)
val role_to_string : Role.t -> string

(** [set_keyboard wm device xkb] sets [device]'s xkb attribute to [xkb] if
    [device] is a keyboard. Logs a warning if [device] is not a keyboard. Sends
    a River request to set the user's configured keymap.

    {b Effects:} mutates WM state; sends River request *)
val set_keyboard : Types.Wm.t -> t -> Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [clear_device device proxy] clears [device] if it is holding [proxy].

    {b Effects:} mutates WM state *)
val clear_device : t -> Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [remove_device device] deletes [device]'s associated Wayland objects. Is a
    no-op if [device] was already removed.

    {b Effects:} mutates WM state; sends River request *)
val remove_device : t -> unit

(** [id proxy] is the protocol object id of [proxy]. The bridge uses it as a map
    key. *)
val id : Wire.Obj.Input.Management.Device.t -> int32

(** [matches device ~pattern ~case ~role] is [true] when [device] matches [role]
    and [pattern] according to [case]. *)
val matches
  :  t
  -> pattern:string option
  -> case:Ocdwm_core.Pattern.Case.t
  -> role:Ocdwm_core.Input.Role.t option
  -> bool
