open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name =
    Arg.(
      required
      & pos 0 (some string) None
      & info
          []
          ~docv:"NAME"
          ~doc:
            "The name of the desired layout. Built-in options include $(i,tile), \
             $(i,monocle), and $(i,floating).")
  in
  Action.Layout_set name
;;

let name = "layout"
let doc = "Set the layout to NAME"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
