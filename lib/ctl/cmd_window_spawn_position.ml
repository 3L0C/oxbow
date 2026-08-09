open! Oxbow_core
open! Oxbow_ipc

let command_term position =
  Cmdliner.Term.const @@ Command.Window (Spawn_position position)
;;

let position_targets =
  List.map
    (fun position -> Spawn_position.to_string position, position)
    Spawn_position.all
;;

let mk_leaf (name, position) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "New windows spawn in the %s position" name)
  @@ command_term position
;;

let name = "position"
let doc = "Set the spawn position of new windows"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf position_targets
