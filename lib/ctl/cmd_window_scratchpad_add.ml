open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name =
    Arg.(
      required
      & pos 0 (some string) None
      & info
          []
          ~doc:"The name of the scratchpad group to add the target window(s) to."
          ~docv:"NAME")
  and+ target = Ctl_cli.target_any_window_term in
  Command.Window (Scratchpad_set { name; target })
;;

let name = "add"
let doc = "Add the target window(s) to the scratchpad group NAME"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
