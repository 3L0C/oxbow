open! Oxbow_core
open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  Term.term_result' ~usage:true
  @@ let+ pattern = Ctl_cli.device_pattern_flag
     and+ case = Ctl_cli.case_flag
     and+ accel_profile = Ctl_cli.accel_profile_flag
     and+ accel_speed = Ctl_cli.accel_speed_flag
     and+ natural_scroll = Ctl_cli.natural_scroll_flag
     and+ left_handed = Ctl_cli.left_handed_flag
     and+ middle_emulation = Ctl_cli.middle_emulation_flag
     and+ scroll_method = Ctl_cli.scroll_method_flag
     and+ scroll_button = Ctl_cli.scroll_button_flag
     and+ scroll_button_lock =
       Ctl_cli.bool_state_flag
         "scroll-button-lock"
         ~doc:
           "Enable or disable the scroll button lock. With the lock, the scroll button \
            toggles, and you do not hold it."
         ~docv:"OPTION"
     and+ send_events = Ctl_cli.send_events_flag
     and+ scroll_factor = Ctl_cli.scroll_factor_flag in
     let settings =
       Input_rule.Mouse.
         { accel_profile
         ; accel_speed
         ; natural_scroll
         ; left_handed
         ; middle_emulation
         ; scroll_method
         ; scroll_button
         ; scroll_button_lock
         ; send_events
         ; scroll_factor
         }
     in
     if settings = Input_rule.Mouse.empty
     then Error "give at least one setting flag"
     else Ok (Command.Input (Rule_add (Mouse { pattern; case; settings })))
;;

let name = "mouse"
let doc = "Add or update a mouse rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
