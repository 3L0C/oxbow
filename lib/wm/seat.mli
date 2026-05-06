type t = Types.Seat.t

(** [init ctx seat] initializes [seat] with default keybindings.

    {b Effects:} mutates WM state; sends River request *)
val init : Ctx.manage Ctx.t -> t -> unit

(** [refresh_cursor_target ctx seat] updates [seat.cursor_target] based
    on the last known cursor position.

    {b Effects:} mutates WM state *)
val refresh_cursor_target : Types.Window_manager.t -> t -> unit

(** [destroy seat] destroys the Wayland objects underlying [seat].

    {b Effects:} mutates WM state; sends River request *)
val destroy : t -> unit

(** [handle_pointer_position wm seat x y] updates the pointer position of [seat]
    and syncs [seat]'s focus request when [focus_follows_pointer] is [true].

    {b Effects:} mutates WM state *)
val handle_pointer_position : Types.Window_manager.t -> t -> x:int32 -> y:int32 -> unit

(** [mark_dirty seat] flags [seat] as dirty for pending layer focus operations.

    {b Effects:} mutates WM state *)
val mark_dirty : t -> unit

(** [sync ctx seat] syncs [seat] and River state

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> t -> unit
