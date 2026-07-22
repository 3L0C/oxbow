open! Ocdwm_core
open! Ocdwm_ipc

let scroll_targets =
  List.map (fun p -> Scroll_policy.to_string p, p) [ Visible; Left; Centered ]
;;

let leaf mk_term (name, policy) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Set the scroll policy to %s" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ Command.Set (Scroll_policy policy)
;;

let name = "scroll"
let doc = "Set the scrolling layout policy"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) scroll_targets
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
