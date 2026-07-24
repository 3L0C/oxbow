open! Ocdwm_core

let focused_output (seat : Types.Seat.t) f =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o -> f o
;;

let focused_window seat f =
  focused_output seat
  @@ fun o ->
  match Output.focused_window o with
  | None -> Error Messages.no_focused_window
  | Some w -> f o w
;;

let output (window : Types.Window.t) f =
  match window.output with
  | None -> Error Messages.window_missing_output
  | Some o -> f o
;;
