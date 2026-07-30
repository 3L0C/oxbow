let name = "gaps"
let doc = "Configure the gaps between windows"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_gaps_inner.cmd; Cmd_gaps_outer.cmd; Cmd_gaps_overview.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_gaps_inner.bind_cmd; Cmd_gaps_outer.bind_cmd; Cmd_gaps_overview.bind_cmd ]
;;
