open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
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
  Command.Window
    (Focus_query
       (if regex
        then { pattern = Regex query; field; cycle }
        else { pattern = Substring query; field; cycle }))
;;

let name = "query"
let doc = "Focus a window matching the search query"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
