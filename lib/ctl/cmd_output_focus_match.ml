open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_output_term
  and+ warp = Ctl_cli.warp_flag in
  Command.Output (Focus_match { target; warp })
;;

let name = "match"
let doc = "Focus the output matching the search pattern"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
