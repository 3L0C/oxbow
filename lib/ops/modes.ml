open! Ocdwm_core
open! Ocdwm_state

let declare (wm : Wm.t) name =
  if List.mem name wm.config.modes
  then Error (Printf.sprintf "mode already declared: %S" name)
  else (
    Config.declare_mode wm name;
    Ok None)
;;

let enter ctx seat name =
  match Seat.set_mode ctx seat name with
  | Error _ as e -> e
  | Ok () -> Ok None
;;
