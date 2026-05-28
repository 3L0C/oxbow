open! Ocdwm_core

let dir_action dir =
  let open Any_direction in
  match dir with
  | Logical d -> Action.Focus_window_logical d
  | Spatial d -> Action.Focus_window_spatial d
;;

let dir_leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Focus the %s window" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ dir_action dir
;;

let query_action_term =
  let open Window_query in
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ query =
    Arg.(
      required
      & pos 0 (some string) None
      & info
          []
          ~docv:"STRING"
          ~doc:"Match windows containing STRING in their title/app-id")
  and+ field =
    Arg.(
      value
      & vflag
          Field.Any
          [ Field.Title, info [ "title" ] ~doc:"Match against window title only"
          ; Field.App_id, info [ "app-id" ] ~doc:"Match againts app-id only"
          ])
  and+ regex =
    Arg.(
      value
      & flag
      & info [ "regex" ] ~doc:"Interpret the search string as a regular expression")
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
  Action.Focus_window_query
    (if regex
     then { query = Regex query; field; cycle }
     else { query = Substring query; field; cycle })
;;

let query_leaf mk_term =
  Ctl_cli.cmd ~name:"query" ~doc:"Focus a window matching the search query"
  @@ mk_term query_action_term
;;

let name = "focus"
let doc = "Focus a window by direction or search query"

let build mk_term =
  Ctl_cli.group ~name ~doc
  @@ (query_leaf mk_term :: List.map (dir_leaf mk_term) Ctl_cli.direction_targets)
;;

let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
