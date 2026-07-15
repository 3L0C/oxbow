open! Ocdwm_state

let apply (seat : Seat.t) ~name ~size =
  River.Window_management.River_seat_v1.set_xcursor_theme seat.obj ~name ~size
;;

let set_theme wm seat name size =
  Config.set_cursor_theme wm @@ Some (name, size);
  apply seat ~name ~size
;;
