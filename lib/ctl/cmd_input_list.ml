open! Ocdwm_core
open! Ocdwm_ipc

let role_arg =
  Ctl_cli.mk_enum "role" ~doc:"Filter to devices with this role." ~docv:"ROLE"
  @@ Ctl_cli.enum_of Input.Role.to_string [ Keyboard; Mouse; Touchpad; Touch; Tablet ]
;;

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ pattern = Ctl_cli.device_pattern_arg
  and+ case = Ctl_cli.case_flag
  and+ role = role_arg in
  Query.Input_devices { pattern; case; role }
;;

let name = "list"
let doc = "List input devices matching the search pattern."
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term command_term
