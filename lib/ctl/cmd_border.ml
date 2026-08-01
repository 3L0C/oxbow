let name = "border"
let doc = "Border configuration commands"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_border_width.(cmd, bind_cmd); Cmd_border_color.(cmd, bind_cmd) ]
;;
