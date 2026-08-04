open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Tiling (Orientation { dir; scope }))
;;

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Position the master stack %s" name)
  @@ command_term dir
;;

let name = "orientation"
let doc = "Set the master orientation for the current layout"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf Ctl_cli.spatial_targets
;;
