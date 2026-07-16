open! Ocdwm_core
open! Ocdwm_ipc

let command_term dir =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ occupied =
    Arg.(value & flag & info [ "occupied" ] ~doc:"Restrict operation to occupied tags")
  in
  if occupied then Command.Tag (View_cycle_occupied dir) else Command.Tag (View_cycle dir)
;;

let leaf mk_term (name, doc, dir) = Ctl_cli.cmd ~name ~doc @@ mk_term @@ command_term dir

let targets =
  List.map
    (fun (s, (d : Direction.Logical.t)) ->
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
let cmds = build Ctl_cli.command_term
let bind_cmds = build Ctl_cli.bind_term
