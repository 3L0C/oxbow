open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ wmatch = Ctl_cli.window_match_term
  and+ tags = Ctl_cli.tag_arg in
  Command.Window (Tag_match { wmatch; tags })
;;

let name = "match"
let doc = "Set TAGS on all windows matching the search pattern"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
