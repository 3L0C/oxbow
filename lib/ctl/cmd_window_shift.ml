open! Oxbow_ipc

let mk_leaf (name, doc, dir) =
  Ctl_cli.cmd_pair ~name ~doc @@ Cmdliner.Term.const (Command.Window (Shift dir))
;;

let targets =
  Ctl_cli.logical_leaves
    ~next:
      "Shift focused window toward the tail of the stack. Wraps to the head if focused \
       window is the tail"
    ~prev:
      "Shift focused window toward the head of the stack. Wraps to the tail if focused \
       window is the head"
;;

let name = "shift"
let doc = "Shift the focused window through the tile stack"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf targets
