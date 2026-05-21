open Ocdwm_core
open Cmdliner
open Cmdliner.Term.Syntax

let cmd =
  let open Window_query in
  let term =
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
  in
  Ctl_cli.cmd_of_term ~name:"window" ~doc:"Focus a window matching the search query" term
;;
