open! Ocdwm_ipc

let mk_leaf (name, doc, dir) =
  Ctl_cli.cmd_pair ~name ~doc
  @@ Cmdliner.Term.const (Command.Window (Command.Window.Column_move dir))
;;

let move_targets =
  Ctl_cli.logical_leaves
    ~next:
      "Shift focused column tail of the stack. Wraps to the head if focused column is \
       the tail"
    ~prev:
      "Shift focused column toward the head of the stack. Wraps to the tail if focused \
       column is the head"
;;

let name = "move"
let doc = "Move the focused column through the strip"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf move_targets
