open Ocdwm_core
open Cmdliner
open Cmdliner.Term.Syntax

let action_term =
  let open Window_query in
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

let name = "window"
let doc = "Focus a window matching the search query"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
