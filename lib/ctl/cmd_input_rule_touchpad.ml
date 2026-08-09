open! Oxbow_core
open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  Term.term_result' ~usage:true
  @@ let+ pattern = Ctl_cli.device_pattern_flag
     and+ case = Ctl_cli.case_flag
     and+ tap =
       Ctl_cli.bool_state_flag "tap" ~doc:"Enable or disable tap-to-click." ~docv:"OPTION"
     and+ tap_button_map =
       Ctl_cli.button_map_flag
         "tap-button-map"
         ~doc:"Set the button order for taps with one, two, or three fingers."
     and+ drag =
       Ctl_cli.bool_state_flag
         "drag"
         ~doc:"Enable or disable tap-and-drag."
         ~docv:"OPTION"
     and+ drag_lock = Ctl_cli.drag_lock_flag
     and+ three_finger_drag = Ctl_cli.three_finger_drag_flag
     and+ dwt =
       Ctl_cli.bool_state_flag
         "disable-while-typing"
         ~doc:"Enable or disable the disable-while-typing feature."
         ~docv:"OPTION"
     and+ dwtp =
       Ctl_cli.bool_state_flag
         "disable-while-trackpointing"
         ~doc:"Enable or disable the disable-while-trackpointing feature."
         ~docv:"OPTION"
     and+ click_method = Ctl_cli.click_method_flag
     and+ clickfinger_button_map =
       Ctl_cli.button_map_flag
         "clickfinger-button-map"
         ~doc:"Set the button order for clicks with one, two, or three fingers."
     and+ accel_profile = Ctl_cli.accel_profile_flag
     and+ accel_speed = Ctl_cli.accel_speed_flag
     and+ natural_scroll = Ctl_cli.natural_scroll_flag
     and+ left_handed = Ctl_cli.left_handed_flag
     and+ middle_emulation = Ctl_cli.middle_emulation_flag
     and+ scroll_method = Ctl_cli.scroll_method_flag
     and+ send_events = Ctl_cli.send_events_flag
     and+ scroll_factor = Ctl_cli.scroll_factor_flag in
     let settings =
       Input_rule.Touchpad.
         { tap
         ; tap_button_map
         ; drag
         ; drag_lock
         ; three_finger_drag
         ; dwt
         ; dwtp
         ; click_method
         ; clickfinger_button_map
         ; accel_profile
         ; accel_speed
         ; natural_scroll
         ; left_handed
         ; middle_emulation
         ; scroll_method
         ; send_events
         ; scroll_factor
         }
     in
     if settings = Input_rule.Touchpad.empty
     then Error "give at least one setting flag"
     else Ok (Command.Input (Rule_add (Touchpad { pattern; case; settings })))
;;

let name = "touchpad"
let doc = "Add or update a touchpad rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
