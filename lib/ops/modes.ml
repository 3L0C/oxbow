open! Ocdwm_state
open! Ocdwm_ipc

(* FIXME modes should probably be per seat *)
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

let handle ctx seat (cmd : Command.Keymap.Mode.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Declare name -> declare wm name
  | Enter name -> enter ctx seat name
;;
