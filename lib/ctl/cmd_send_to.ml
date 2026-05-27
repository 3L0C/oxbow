let name = "send-to"
let doc = "Send the focused window to an output by name or direction"

let cmd =
  Ctl_cli.group ~name ~doc @@ (Cmd_send_to_output.cmd :: Cmd_send_to_direction.cmds)
;;

let bind_cmd =
  Ctl_cli.group ~name ~doc @@ (Cmd_send_to_output.bind_cmd :: Cmd_send_to_direction.binds)
;;
