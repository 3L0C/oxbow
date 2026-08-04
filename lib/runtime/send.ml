open! Ocdwm_state

let show (_ : Ctx.render Ctx.t) (w : Window.t) =
  River.Window_management.River_window_v1.show w.obj
;;

let hide (_ : Ctx.render Ctx.t) (w : Window.t) =
  River.Window_management.River_window_v1.hide w.obj
;;

let close (_ : Ctx.manage Ctx.t) (w : Window.t) =
  River.Window_management.River_window_v1.close w.obj
;;

let propose_dimensions (_ : Ctx.manage Ctx.t) (w : Window.t) ~width ~height =
  if w.committed.proposed <> Some (width, height)
  then (
    River.Window_management.River_window_v1.propose_dimensions w.obj ~width ~height;
    Window.set_proposed w (Some (width, height)))
;;

let fullscreen (_ : Ctx.manage Ctx.t) (w : Window.t) ~(output : Output.t) =
  let id = Some (Wayland.Proxy.id output.obj) in
  if w.committed.fullscreen_on <> id
  then (
    River.Window_management.River_window_v1.fullscreen w.obj ~output:output.obj;
    Window.set_fullscreen_on w id)
;;

let exit_fullscreen (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.fullscreen_on <> None
  then (
    River.Window_management.River_window_v1.exit_fullscreen w.obj;
    Window.set_fullscreen_on w None;
    Window.set_proposed w None)
;;

let inform_fullscreen (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.informed_fullscreen <> Some true
  then (
    River.Window_management.River_window_v1.inform_fullscreen w.obj;
    Window.set_informed_fullscreen w (Some true))
;;

let inform_not_fullscreen (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.informed_fullscreen <> Some false
  then (
    River.Window_management.River_window_v1.inform_not_fullscreen w.obj;
    Window.set_informed_fullscreen w (Some false))
;;

let inform_maximized (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.informed_maximized <> Some true
  then (
    River.Window_management.River_window_v1.inform_maximized w.obj;
    Window.set_informed_maximized w (Some true))
;;

let inform_unmaximized (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.informed_maximized <> Some false
  then (
    River.Window_management.River_window_v1.inform_unmaximized w.obj;
    Window.set_informed_maximized w (Some false))
;;

let inform_resize_start (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.informed_resizing <> Some true
  then (
    River.Window_management.River_window_v1.inform_resize_start w.obj;
    Window.set_informed_resizing w (Some true))
;;

let inform_resize_end (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.informed_resizing <> Some false
  then (
    River.Window_management.River_window_v1.inform_resize_end w.obj;
    Window.set_informed_resizing w (Some false))
;;

let set_capabilities (_ : Ctx.manage Ctx.t) (w : Window.t) ~caps =
  if w.committed.caps <> Some caps
  then (
    River.Window_management.River_window_v1.set_capabilities w.obj ~caps;
    Window.set_caps w (Some caps))
;;

let set_tiled (_ : Ctx.manage Ctx.t) (w : Window.t) ~edges =
  if w.committed.tiled_edges <> Some edges
  then (
    River.Window_management.River_window_v1.set_tiled w.obj ~edges;
    Window.set_tiled_edges w (Some edges))
;;

let use_csd (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.ssd <> Some false
  then (
    River.Window_management.River_window_v1.use_csd w.obj;
    Window.set_ssd w (Some false))
;;

let use_ssd (_ : Ctx.manage Ctx.t) (w : Window.t) =
  if w.committed.ssd <> Some true
  then (
    River.Window_management.River_window_v1.use_ssd w.obj;
    Window.set_ssd w (Some true))
;;

let focus_window (_ : Ctx.manage Ctx.t) (s : Seat.t) (w : Window.t) =
  River.Window_management.River_seat_v1.focus_window s.obj ~window:w.obj
;;

let clear_focus (_ : Ctx.manage Ctx.t) (s : Seat.t) =
  River.Window_management.River_seat_v1.clear_focus s.obj
;;

let op_start_pointer (_ : Ctx.manage Ctx.t) (s : Seat.t) =
  River.Window_management.River_seat_v1.op_start_pointer s.obj
;;

let op_end (_ : Ctx.manage Ctx.t) (s : Seat.t) =
  River.Window_management.River_seat_v1.op_end s.obj
;;

let pointer_warp (_ : Ctx.manage Ctx.t) (s : Seat.t) ~x ~y =
  River.Window_management.River_seat_v1.pointer_warp s.obj ~x ~y;
  Seat.set_position s (x, y)
;;

let set_position (_ : Ctx.render Ctx.t) (w : Window.t) ~x ~y =
  River.Window_management.River_node_v1.set_position w.node ~x ~y
;;

let set_clip_box (_ : Ctx.render Ctx.t) (w : Window.t) ~x ~y ~width ~height =
  River.Window_management.River_window_v1.set_clip_box w.obj ~x ~y ~width ~height
;;

let set_content_clip_box (_ : Ctx.render Ctx.t) (w : Window.t) ~x ~y ~width ~height =
  River.Window_management.River_window_v1.set_content_clip_box w.obj ~x ~y ~width ~height
;;

let set_borders (_ : Ctx.render Ctx.t) (w : Window.t) ~edges ~width ~r ~g ~b ~a =
  if w.committed.borders <> Some (edges, width, r, g, b, a)
  then (
    River.Window_management.River_window_v1.set_borders w.obj ~edges ~width ~r ~g ~b ~a;
    Window.set_borders w (Some (edges, width, r, g, b, a)))
;;

let place_top (_ : Ctx.render Ctx.t) (w : Window.t) =
  River.Window_management.River_node_v1.place_top w.node
;;

let set_presentation_mode (_ : Ctx.render Ctx.t) (o : Output.t) ~mode =
  River.Window_management.River_output_v1.set_presentation_mode o.obj ~mode
;;

let enable_xkb_binding (_ : Ctx.manage Ctx.t) binding =
  River.Xkb.Bindings.River_xkb_binding_v1.enable binding
;;

let disable_xkb_binding (_ : Ctx.manage Ctx.t) binding =
  River.Xkb.Bindings.River_xkb_binding_v1.disable binding
;;

let enable_pointer_binding (_ : Ctx.manage Ctx.t) pointer =
  River.Window_management.River_pointer_binding_v1.enable pointer
;;

let disable_pointer_binding (_ : Ctx.manage Ctx.t) pointer =
  River.Window_management.River_pointer_binding_v1.disable pointer
;;

let modifiers_watch (_ : Ctx.manage Ctx.t) (s : Seat.t) =
  if s.watch_sent <> s.overview_watch
  then (
    River.Xkb.Bindings.River_xkb_bindings_seat_v1.modifiers_watch
      s.xkb_seat
      ~modifiers:s.overview_watch;
    Seat.set_watch_sent s s.overview_watch)
;;
