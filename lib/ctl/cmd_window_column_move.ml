open! Ocdwm_core
open! Ocdwm_ipc

let leaf mk_term (name, doc, command) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const (Command.Window command)
;;

let move_targets =
  List.map
    (fun (name, dir) ->
       ( name
       , (match (dir : Direction.Logical.t) with
          | Next ->
            "Shift focused column tail of the stack. Wraps to the head if focused column \
             is the tail"
          | Prev ->
            "Shift focused column toward the head of the stack. Wraps to the tail if \
             focused column is the head")
       , Command.Window.Column_move dir ))
    Ctl_cli.logical_targets
;;

let name = "move"
let doc = "Move the focused column through the strip"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) move_targets
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
