module Rwm = Ocdwm_protocol.River_window_management_v1_client

let apply (seat : Types.Seat.t) ~name ~size =
  Rwm.River_seat_v1.set_xcursor_theme seat.obj ~name ~size
;;

let set_theme (wm : Types.Window_manager.t) (seat : Types.Seat.t) ~name ~size =
  apply seat ~name ~size;
  wm.config.cursor_theme <- Some (name, size)
;;
