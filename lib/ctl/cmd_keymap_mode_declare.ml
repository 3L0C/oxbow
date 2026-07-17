open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name =
    Arg.(required & pos 0 (some string) None & info [] ~docv:"MODE" ~doc:"The mode name")
  in
  Command.Mode (Declare name)
;;

let name = "declare"
let doc = "Declare a new keymap mode"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
