open! Ocdwm_core
open! Ocdwm_ipc

let command_term kind =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Stack { kind; global })
;;

let stack_targets =
  List.map (fun k -> Stack_kind.to_string k, k) [ Even; Diminish; Dwindle; Spiral ]
;;

let leaf mk_term (name, kind) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Make the stack %s" name)
  @@ mk_term
  @@ command_term kind
;;

let name = "stack"
let doc = "Set the stacking behavior for the current layout"

let build mk_term extra =
  Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) stack_targets @ extra
;;

let cmd = build Ctl_cli.command_term Cmd_layout_tiling_stack_cycle.cmds
let bind_cmd = build Ctl_cli.bind_term Cmd_layout_tiling_stack_cycle.bind_cmds
