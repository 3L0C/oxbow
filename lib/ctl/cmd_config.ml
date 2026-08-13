let name = "config"
let doc = "Configuration operations"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc [ Cmd_config_reset.(cmd, bind_cmd) ]
