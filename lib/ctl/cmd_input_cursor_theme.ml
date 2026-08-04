open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name = Arg.(required & pos 0 (some string) None & info [] ~docv:"NAME")
  and+ size = Arg.(required & pos 1 (some int32) None & info [] ~docv:"SIZE") in
  Command.Input (Cursor (Theme { name; size }))
;;

let name = "theme"
let doc = "Set the XCursor theme to NAME and SIZE"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
