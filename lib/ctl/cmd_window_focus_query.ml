open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Window_query in
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ pattern = Ctl_cli.window_query_pattern_arg
  and+ field = Ctl_cli.window_query_field_flag
  and+ regex = Ctl_cli.window_query_regex_flag
  and+ case = Ctl_cli.window_query_case_flag
  and+ cycle =
    Arg.(
      value
      & flag
      & info
          [ "cycle" ]
          ~doc:
            "If the currently focused window matches the search term, focus the next \
             matching window, if any")
  in
  let query =
    let pattern : Pattern.t = if regex then Regex pattern else Substring pattern in
    { pattern; field; case }
  in
  Command.Window (Focus_query { query; cycle })
;;

let name = "query"
let doc = "Focus a window matching the search query"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
