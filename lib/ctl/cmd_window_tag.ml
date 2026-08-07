let name = "tag"
let doc = "Set the active TAGS on a window"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_window_tag_set.(cmd, bind_cmd); Cmd_window_tag_shift.(cmd, bind_cmd) ]
;;
