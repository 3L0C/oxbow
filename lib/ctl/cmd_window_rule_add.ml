open! Oxbow_core
open! Oxbow_ipc

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
     and+ move_to = Ctl_cli.move_to_flag
     and+ sticky = Ctl_cli.sticky_flag
     and+ swallow = Ctl_cli.swallow_flag
     and+ label_as = Ctl_cli.label_as_flag
     and+ spawn_position = Ctl_cli.spawn_position_flag
     and+ spawn_focus = Ctl_cli.spawn_focus_flag in
     let output : Window_rule.Effects.Output.t option =
       match name with
       | None -> None
       | Some name -> Some { name; policy }
     in
     let effects : Window_rule.Effects.t =
       { output
       ; tags
       ; presentation
       ; resize_to
       ; move_to
       ; sticky
       ; swallow
       ; label_as
       ; spawn_position
       ; spawn_focus
       }
     in
     if Window_rule.Effects.is_empty effects
     then Error "give at least one effect"
     else Ok (Command.Window (Rule_add { pattern; effects }))
;;

let name = "add"
let doc = "Add a window rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
