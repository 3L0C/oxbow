let name = "label"
let doc = "Manage output labels"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_output_label_add.(cmd, bind_cmd); Cmd_output_label_remove.(cmd, bind_cmd) ]
;;
