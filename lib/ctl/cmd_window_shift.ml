open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window (Shift { dir; target })
;;

let mk_leaf (name, doc, dir) = Ctl_cli.cmd_pair ~name ~doc @@ command_term dir

let targets =
  Ctl_cli.logical_leaves
    ~next:
      "Shift target window toward the tail of the stack. Wraps to the head if target \
       window is the tail"
    ~prev:
      "Shift target window toward the head of the stack. Wraps to the tail if target \
       window is the head"
;;

let name = "shift"
let doc = "Shift the target window through the tile stack"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf targets
