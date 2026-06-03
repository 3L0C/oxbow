open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name = Arg.(required & pos 0 (some string) None & info [] ~docv:"NAME")
  and+ size = Arg.(required & pos 1 (some int) None & info [] ~docv:"SIZE") in
  Action.Set_cursor_theme { name; size }
;;

let name = "theme"
let doc = "Set the XCursor theme to NAME and SIZE"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
