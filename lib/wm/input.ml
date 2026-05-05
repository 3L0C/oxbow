module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Utils = Ocdwm_core.Utils
module Tag_set = Ocdwm_core.Tag_set
module Layout = Ocdwm_layout.Layout
module Window_request = Types.Window_request
open Ocdwm_core.Types

let pointer_move (ctx : Ctx.manage Ctx.t) (s : Seat.t) (window : Window.t) =
  Focus.focus_window ctx s window;
  Rwm.River_seat_v1.op_start_pointer s.obj;
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
      (s : Seat.t)
      (window : Window.t)
      (edges : int32)
  =
  Focus.focus_window ctx s window;
  Rwm.River_window_v1.inform_resize_start window.obj;
  Rwm.River_seat_v1.op_start_pointer s.obj;
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
