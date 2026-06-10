type t = Types.Seat.t

(** [unbind_xkb_binding ctx seat mods keysym] destroys the keybind matching
    [mods]+[keysym], if it exists.

   {b Effects:} mutates WM state; sends River request *)
val unbind_xkb_binding : Ctx.manage Ctx.t -> t -> int32 -> Xkbcommon.Keysym.t -> unit

(** [replace_xkb_binding ctx seat mods keysym action] replaces the existing
    binding matching [mods] and [keysym] with [action].

   {b Effects:} mutates WM state; sends River request *)
val replace_xkb_binding
  :  Ctx.manage Ctx.t
  -> t
  -> int32
  -> Xkbcommon.Keysym.t
  -> Ocdwm_core.Action.t
  -> unit

(** [unbind_pointer_binding ctx seat mods button] destroys the keybind matching
    [mods]+[button], if it exists.

   {b Effects:} mutates WM state; sends River request *)
val unbind_pointer_binding : Ctx.manage Ctx.t -> t -> int32 -> Input_event.t -> unit

(** [replace_pointer_binding ctx seat mods button action] replaces the existing
    binding matching [mods] and [button] with [action].

   {b Effects:} mutates WM state; sends River request *)
val replace_pointer_binding
  :  Ctx.manage Ctx.t
  -> t
  -> int32
  -> Input_event.t
  -> Ocdwm_core.Action.t
  -> unit

(** [init ctx seat] initializes [seat] with default keybindings.

    {b Effects:} mutates WM state; sends River request *)
val init : Ctx.manage Ctx.t -> t -> unit

(** [destroy ctx seat] destroys the Wayland objects underlying [seat].

    {b Effects:} mutates WM state; sends River request *)
val destroy : Ctx.manage Ctx.t -> t -> unit

(** [handle_pointer_position wm seat x y] updates the pointer position of [seat]
    and syncs [seat]'s focus request when [focus_follows_pointer] is [true].

    {b Effects:} mutates WM state *)
val handle_pointer_position : Types.Window_manager.t -> t -> x:int32 -> y:int32 -> unit

(** [mark_dirty wm seat] flags [seat] as dirty for pending layer focus operations.

    {b Effects:} mutates WM state; sends River request *)
val mark_dirty : Types.Window_manager.t -> t -> unit

(** [sync ctx seat] syncs [seat] and River state

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> t -> unit

(** [op_end ctx seat] ends any operation on [seat].

   {b Effects:} mutates WM state; sends River request *)
val op_end : Ctx.manage Ctx.t -> t -> unit
