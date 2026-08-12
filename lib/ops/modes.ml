open! Oxbow_core
open! Oxbow_state
open! Oxbow_ipc
open! Result.Syntax

let declare (wm : Wm.t) name =
  let+ mode = Mode.declare name ~declared:wm.config.modes in
  Config.declare_mode wm mode;
  None
;;

let enter (wm : Wm.t) seat name =
  let* mode = Mode.resolve name ~declared:wm.config.modes in
  let+ () = Seat.set_mode seat mode in
  None
;;

let handle wm seat (cmd : Command.Keymap.Mode.t) =
  match cmd with
  | Declare name -> declare wm name
  | Enter name -> enter wm seat name
;;
