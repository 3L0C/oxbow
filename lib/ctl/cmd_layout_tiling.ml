open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Select { layout = Tiling; scope })
;;

let name = "tiling"
let doc = "Switch to the tiling layout"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~default:command_term
    ~extra:[ Cmd_layout_tiling_query.cmd ]
  @@ Cmd_layout_tiling_cycle.(List.combine cmds bind_cmds)
  @ Cmd_layout_tiling_scheme.(List.combine cmds bind_cmds)
  @ [ Cmd_layout_tiling_mfact.(cmd, bind_cmd)
    ; Cmd_layout_tiling_nmaster.(cmd, bind_cmd)
    ; Cmd_layout_tiling_orientation.(cmd, bind_cmd)
    ]
;;
