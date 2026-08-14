open! Oxbow_ipc

let command_term, bind_command_term =
  Ctl_cli.swap_terms
  @@ fun ~target ~policy ~follow -> Command.Output (Swap (All { target; policy; follow }))
;;

let name = "all"
let doc = "Swap all windows between two outputs"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc ~bind:bind_command_term command_term
