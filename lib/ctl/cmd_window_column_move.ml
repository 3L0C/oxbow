open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window { cmd = Command.Window.Column_move dir; target }
;;

let mk_leaf (name, doc, dir) = Ctl_cli.cmd_pair ~name ~doc @@ command_term dir

let move_targets =
  Ctl_cli.logical_leaves
    ~next:
      "Shift focused column tail of the stack. Wraps to the head if target column is the \
       tail"
    ~prev:
      "Shift focused column toward the head of the stack. Wraps to the tail if target \
       column is the head"
;;

let name = "move"
let doc = "Move the target column through the strip"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf move_targets
