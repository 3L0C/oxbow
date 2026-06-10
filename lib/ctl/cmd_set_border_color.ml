open! Ocdwm_core

let action_term which =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ color = Arg.(required & pos 0 (some int32) None & info [] ~docv:"HEX") in
  Action.Set_border_color { which; color }
;;

let leaves =
  [ "focused", Border_target.Focused
  ; "unfocused", Border_target.Unfocused
  ; "urgent", Border_target.Urgent
  ]
;;

let mk_leaf mk_term (name, which) =
  Ctl_cli.cmd
    ~name
    ~doc:(Printf.sprintf "Set the border color when the window state is %s" name)
  @@ mk_term
  @@ action_term which
;;

let name = "color"
let doc = "Set the window color for a given state"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (mk_leaf mk_term) leaves
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
