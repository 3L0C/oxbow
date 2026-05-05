open Ocdwm_core.Types

(** [pointer_move ctx seat window] focuses [window] and begins the pointer move
    operation on [seat].

    {b Effects:} mutates WM state; sends River request *)
val pointer_move : Ctx.manage Ctx.t -> Seat.t -> Window.t -> unit

(** [pointer_move ctx seat window] focuses [window] and begins the pointer resize
    operation on [seat] and [window].

    {b Effects:} mutates WM state; sends River request *)
val pointer_resize : Ctx.manage Ctx.t -> Seat.t -> Window.t -> int32 -> unit
