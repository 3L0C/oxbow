open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  Term.term_result' ~usage:true
  @@ let+ pattern = Ctl_cli.pattern_term
     and+ name = Ctl_cli.output_flag
     and+ policy = Ctl_cli.policy_flag
     and+ tags = Ctl_cli.tags_flag
     and+ presentation = Ctl_cli.presentation_flag
     and+ resize_to = Ctl_cli.resize_to_flag
     and+ move_to = Ctl_cli.move_to_flag in
     let output : Window_rule.Effects.Output.t option =
       match name with
       | None -> None
       | Some name -> Some { name; policy }
     in
     let effects : Window_rule.Effects.t =
       { output; tags; presentation; resize_to; move_to }
     in
     if Window_rule.Effects.is_empty effects
     then Error "give at least one effect"
     else Ok (Command.Window (Rule_add { pattern; effects }))
;;

let name = "add"
let doc = "Add a window rule"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
