(** [propose_dimensions ctx window ~width ~height] proposes content dimensions
    to [window].

    {b Effects:} sends River request *)
val propose_dimensions
  :  Ctx.manage Ctx.t
  -> Ocdwm_state.Window.t
  -> width:int32
  -> height:int32
  -> unit

(** [show ctx window] makes river show [window].

    {b Effects:} sends River request *)
val show : Ctx.render Ctx.t -> Ocdwm_state.Window.t -> unit

(** [hide ctx window] makes river hide [window].

    {b Effects:} sends River request *)
val hide : Ctx.render Ctx.t -> Ocdwm_state.Window.t -> unit

(** [close ctx window] asks [window] to close.

    {b Effects:} sends River request *)
val close : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [fullscreen ctx window ~output] makes [window] fullscreen
    on [output].

    {b Effects:} sends River request *)
val fullscreen
  :  Ctx.manage Ctx.t
  -> Ocdwm_state.Window.t
  -> output:Ocdwm_state.Output.t
  -> unit

(** [exit_fullscreen ctx window] takes [window] out of the fullscreen state.

    {b Effects:} sends River request *)
val exit_fullscreen : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [inform_fullscreen ctx window] tells [window] it is fullscreen.

    {b Effects:} sends River request *)
val inform_fullscreen : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [inform_not_fullscreen ctx window] tells [window] it is not fullscreen.

    {b Effects:} sends River request *)
val inform_not_fullscreen : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [inform_maximized ctx window] tells [window] it is maximized.

    {b Effects:} sends River request *)
val inform_maximized : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [inform_unmaximized ctx window] tells [window] it is not maximized.

    {b Effects:} sends River request *)
val inform_unmaximized : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [inform_resize_start ctx window] tells [window] an interactive resize
    started.

    {b Effects:} sends River request *)
val inform_resize_start : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [inform_resize_end ctx window] tells [window] the interactive resize ended.

    {b Effects:} sends River request *)
val inform_resize_end : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [set_capabilities ctx window ~caps] sets the capabilities of [window].

    {b Effects:} sends River request *)
val set_capabilities : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> caps:int32 -> unit

(** [set_tiled ctx window ~edges] marks the tiled edges of [window].

    {b Effects:} sends River request *)
val set_tiled : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> edges:int32 -> unit

(** [use_csd ctx window] asks [window] to draw client-side
    decorations.

    {b Effects:} sends River request *)
val use_csd : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [use_ssd ctx window] asks river to draw server-side decorations on [window].

    {b Effects:} sends River request *)
val use_ssd : Ctx.manage Ctx.t -> Ocdwm_state.Window.t -> unit

(** [focus_window ctx seat window] gives [window] the keyboard focus of [seat].

    {b Effects:} sends River request *)
val focus_window : Ctx.manage Ctx.t -> Ocdwm_state.Seat.t -> Ocdwm_state.Window.t -> unit

(** [clear_focus ctx seat] clears the keyboard focus of [seat].

    {b Effects:} sends River request *)
val clear_focus : Ctx.manage Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [op_start_pointer ctx seat] starts a pointer operation on [seat].

    {b Effects:} sends River request *)
val op_start_pointer : Ctx.manage Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [op_end ctx seat] ends the pointer operation on [seat].

    {b Effects:} sends River request *)
val op_end : Ctx.manage Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [pointer_warp ctx seat ~x ~y] warps the pointer of [seat] to ([x], [y]).

    {b Effects:} sends River request *)
val pointer_warp : Ctx.manage Ctx.t -> Ocdwm_state.Seat.t -> x:int32 -> y:int32 -> unit

(** [set_position ctx window ~x ~y] positions the node of [window] at
    ([x], [y]).

    {b Effects:} sends River request *)
val set_position : Ctx.render Ctx.t -> Ocdwm_state.Window.t -> x:int32 -> y:int32 -> unit

(** [set_clip_box ctx window ~x ~y ~width ~height] clips [window] to the given
    box. All zeros clears the clip.

    {b Effects:} sends River request *)
val set_clip_box
  :  Ctx.render Ctx.t
  -> Ocdwm_state.Window.t
  -> x:int32
  -> y:int32
  -> width:int32
  -> height:int32
  -> unit

(** [set_content_clip_box ctx window ~x ~y ~width ~height] clips [window] to the
    given box. All zeros clears the clip.

    {b Effects:} sends River request *)
val set_content_clip_box
  :  Ctx.render Ctx.t
  -> Ocdwm_state.Window.t
  -> x:int32
  -> y:int32
  -> width:int32
  -> height:int32
  -> unit

(** [set_borders ctx window ~edges ~width ~r ~g ~b ~a] draws borders on
    [window].

    {b Effects:} sends River request *)
val set_borders
  :  Ctx.render Ctx.t
  -> Ocdwm_state.Window.t
  -> edges:int32
  -> width:int32
  -> r:int32
  -> g:int32
  -> b:int32
  -> a:int32
  -> unit

(** [place_top ctx window] raises the node of [window].

    {b Effects:} sends River request *)
val place_top : Ctx.render Ctx.t -> Ocdwm_state.Window.t -> unit

(** [set_presentation_mode ctx output ~mode] sets the presentation mode of
    [output].

    {b Effects:} sends River request *)
val set_presentation_mode
  :  Ctx.render Ctx.t
  -> Ocdwm_state.Output.t
  -> mode:Wire.Presentation_mode.t
  -> unit

(** [enable_xkb_binding ctx xkb_obj] enables the binding bound to [xkb_obj].

    {b Effects:} sends River request *)
val enable_xkb_binding : Ctx.manage Ctx.t -> River.Obj.Xkb.Bindings.Binding.t -> unit

(** [disable_xkb_binding ctx xkb_obj] disables the binding bound to [xkb_obj].

    {b Effects:} sends River request *)
val disable_xkb_binding : Ctx.manage Ctx.t -> River.Obj.Xkb.Bindings.Binding.t -> unit

(** [enable_pointer_binding ctx pointer_obj] enables the binding bound to
    [pointer_obj].

    {b Effects:} sends River request *)
val enable_pointer_binding
  :  Ctx.manage Ctx.t
  -> River.Obj.Window_management.Pointer_binding.t
  -> unit

(** [disable_pointer_binding ctx pointer_obj] disables the binding bound to
    [pointer_obj].

    {b Effects:} sends River request *)
val disable_pointer_binding
  :  Ctx.manage Ctx.t
  -> River.Obj.Window_management.Pointer_binding.t
  -> unit

(** [modifiers_watch ctx seat] sends the watch request for [seat] when the
    desired set differs from the sent set.

    {b Effects:} sends River request *)
val modifiers_watch : Ctx.manage Ctx.t -> Ocdwm_state.Seat.t -> unit
