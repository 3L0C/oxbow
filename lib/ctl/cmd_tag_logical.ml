open! Ocdwm_core

let action_term dir =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ occupied =
    Arg.(value & flag & info [ "occupied" ] ~doc:"Restrict operation to occupied tags")
  in
  if occupied then Action.Tag_view_cycle_occupied dir else Action.Tag_view_cycle dir
;;

let leaf mk_term (name, doc, dir) = Ctl_cli.cmd ~name ~doc @@ mk_term @@ action_term dir

let targets =
  List.map
    (fun (s, (d : Logical_direction.t)) ->
       match d with
       | Next ->
         ( s
         , "View the next tag, wraps back to the first tag when called from the last tag"
         , d )
       | Prev ->
         ( s
         , "View the previous tag, wraps back to the last tag when viewing the first tag"
         , d ))
    Ctl_cli.logical_targets
;;

let build mk_term = List.map (leaf mk_term) targets
let cmds = build Ctl_cli.trigger_term
let bind_cmds = build Ctl_cli.bind_term
