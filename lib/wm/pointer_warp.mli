(** [warp_to_focus ctx seat] warps the pointer to the center of the [seat]'s
    focused  window when [wm.config.warp_on_focus] is set to [true]. If the seat
    has no focused window,  warps to the center of its focused output instead.
    No-op when [warp_on_focus] is [false].

   {b Effects:} sends River request *)
val warp_to_focus : Ctx.manage Ctx.t -> Types.Seat.t -> unit
