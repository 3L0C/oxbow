open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Select { layout = Scrolling; scope })
;;

let name = "scrolling"
let doc = "Switch to the scrolling layout"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~default:command_term
    [ Cmd_layout_scrolling_default_width.(cmd, bind_cmd)
    ; Cmd_layout_scrolling_policy.(cmd, bind_cmd)
    ]
;;
