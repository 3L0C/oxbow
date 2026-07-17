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
  let wm = Ctx.wm ctx in
  if not @@ List.mem name wm.config.modes
  then Error (Printf.sprintf "mode not declared: %S" name)
  else if String.equal name Mode.locked
  then Error "cannot enter 'locked' mode manually"
  else (
    Seat.set_mode seat name;
    Ok None)
;;
