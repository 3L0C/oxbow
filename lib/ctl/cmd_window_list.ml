open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Window_query in
  let open Cmdliner.Term.Syntax in
  let+ pattern = Ctl_cli.window_query_pattern_opt_arg
  and+ field = Ctl_cli.window_query_field_flag
  and+ regex = Ctl_cli.window_query_regex_flag
  and+ case = Ctl_cli.window_query_case_flag in
  let query =
    Option.bind pattern (fun p ->
      let pattern : Pattern.t = if regex then Regex p else Substring p in
      Some { pattern; field; case })
  in
  Query.Windows { query }
;;

let name = "list"
let doc = "List windows matching the search query"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term command_term
