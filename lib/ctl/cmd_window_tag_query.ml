open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Window_query in
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ pattern = Ctl_cli.window_query_pattern_arg
  and+ field = Ctl_cli.window_query_field_flag
  and+ regex = Ctl_cli.window_query_regex_flag
  and+ tags = Ctl_cli.tag_arg_at 1 in
  let query =
    if regex
    then { pattern = Regex pattern; field }
    else { pattern = Substring pattern; field }
  in
  Command.Window (Tag_query { query; tags })
;;

let name = "query"
let doc = "Set TAGS on all windows matching the search query"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
