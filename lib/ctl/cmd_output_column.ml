let name = "column"
let doc = "Operate on the columns of the focused output"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc [ Cmd_output_column_width.(cmd, bind_cmd) ]
;;
