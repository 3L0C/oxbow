let propose_dimensions (_ : Ctx.manage Ctx.t) (w : Types.Window.t) ~width ~height =
  River.Window_management.River_window_v1.propose_dimensions w.obj ~width ~height
;;

let show (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.show w.obj
;;

let hide (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.hide w.obj
;;

let close (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.close w.obj
;;

let fullscreen (_ : Ctx.manage Ctx.t) (w : Types.Window.t) ~(output : Types.Output.t) =
  River.Window_management.River_window_v1.fullscreen w.obj ~output:output.obj
;;

let exit_fullscreen (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.exit_fullscreen w.obj
;;

let inform_fullscreen (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.inform_fullscreen w.obj
;;

let inform_not_fullscreen (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.inform_not_fullscreen w.obj
;;

let inform_maximized (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.inform_maximized w.obj
;;

let inform_unmaximized (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.inform_unmaximized w.obj
;;

let inform_resize_start (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.inform_resize_start w.obj
;;

let inform_resize_end (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.inform_resize_end w.obj
;;

let set_capabilities (_ : Ctx.manage Ctx.t) (w : Types.Window.t) ~caps =
  River.Window_management.River_window_v1.set_capabilities w.obj ~caps
;;

let set_tiled (_ : Ctx.manage Ctx.t) (w : Types.Window.t) ~edges =
  River.Window_management.River_window_v1.set_tiled w.obj ~edges
;;

let use_csd (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.use_csd w.obj
;;

let use_ssd (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.use_ssd w.obj
;;

let focus_window (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) (w : Types.Window.t) =
  River.Window_management.River_seat_v1.focus_window s.obj ~window:w.obj
;;

let clear_focus (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) =
  River.Window_management.River_seat_v1.clear_focus s.obj
;;

let op_start_pointer (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) =
  River.Window_management.River_seat_v1.op_start_pointer s.obj
;;

let op_end (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) =
  River.Window_management.River_seat_v1.op_end s.obj
;;

let pointer_warp (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) ~x ~y =
  River.Window_management.River_seat_v1.pointer_warp s.obj ~x ~y
;;

let set_position (_ : Ctx.([< manage | render ]) Ctx.t) (w : Types.Window.t) ~x ~y =
  River.Window_management.River_node_v1.set_position w.node ~x ~y
;;

let place_top (_ : Ctx.([< manage | render ]) Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_node_v1.place_top w.node
;;

let set_clip_box
      (_ : Ctx.([< manage | render ]) Ctx.t)
      (w : Types.Window.t)
      ~x
      ~y
      ~width
      ~height
  =
  River.Window_management.River_window_v1.set_clip_box w.obj ~x ~y ~width ~height
;;

let set_borders
      (_ : Ctx.([< manage | render ]) Ctx.t)
      (w : Types.Window.t)
      ~edges
      ~width
      ~r
      ~g
      ~b
      ~a
  =
  River.Window_management.River_window_v1.set_borders w.obj ~edges ~width ~r ~g ~b ~a
;;

let set_presentation_mode
      (_ : Ctx.([< manage | render ]) Ctx.t)
      (o : Types.Output.t)
      ~(mode : River.Window_management.River_output_v1.Presentation_mode.t)
  =
  River.Window_management.River_output_v1.set_presentation_mode o.obj ~mode
;;
