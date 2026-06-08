let pointer_move (ctx : Ctx.manage Ctx.t) (s : Types.Seat.t) (window : Types.Window.t) =
  Focus.focus_window ctx s window;
  River.Window_management.River_seat_v1.op_start_pointer s.obj;
  s.op
  <- Op_move
       { window
       ; start_x = window.geom.x
       ; start_y = window.geom.y
       ; dx = 0l
       ; dy = 0l
       ; release = false
       }
;;

let pointer_resize
      (ctx : Ctx.manage Ctx.t)
      (s : Types.Seat.t)
      (window : Types.Window.t)
      (edges : int32)
  =
  Focus.focus_window ctx s window;
  River.Window_management.River_window_v1.inform_resize_start window.obj;
  River.Window_management.River_seat_v1.op_start_pointer s.obj;
  s.op
  <- Op_resize
       { window
       ; edges
       ; start_x = window.geom.x
       ; start_y = window.geom.y
       ; start_w = window.geom.w
       ; start_h = window.geom.h
       ; dx = 0l
       ; dy = 0l
       ; release = false
       }
;;
