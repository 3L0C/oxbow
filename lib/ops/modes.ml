open! Oxbow_state
open! Oxbow_ipc

let declare (wm : Wm.t) name =
  if List.mem name wm.config.modes
  then Error (Printf.sprintf "mode already declared: %S" name)
  else (
    Config.declare_mode wm name;
    Ok None)
;;

let enter wm seat name =
  match Seat.set_mode wm seat name with
  | Error _ as e -> e
  | Ok () -> Ok None
;;

let handle wm seat (cmd : Command.Keymap.Mode.t) =
  match cmd with
  | Declare name -> declare wm name
  | Enter name -> enter wm seat name
;;
