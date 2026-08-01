open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  Term.term_result' ~usage:true
  @@ let+ name = Ctl_cli.device_name_arg
     and+ case = Ctl_cli.case_flag
     and+ tap =
       Ctl_cli.bool_state_arg "tap" ~doc:"Enable or disable tap-to-click." ~docv:"OPTION"
     and+ tap_button_map =
       Ctl_cli.button_map_arg
         "tap-button-map"
         ~doc:"Set the button order for taps with one, two, or three fingers."
     and+ drag =
       Ctl_cli.bool_state_arg "drag" ~doc:"Enable or disable tap-and-drag." ~docv:"OPTION"
     and+ drag_lock = Ctl_cli.drag_lock_arg
     and+ three_finger_drag = Ctl_cli.three_finger_drag_arg
     and+ dwt =
       Ctl_cli.bool_state_arg
         "disable-while-typing"
         ~doc:"Enable or disable the disable-while-typing feature."
         ~docv:"OPTION"
     and+ dwtp =
       Ctl_cli.bool_state_arg
         "disable-while-trackpointing"
         ~doc:"Enable or disable the disable-while-trackpointing feature."
         ~docv:"OPTION"
     and+ click_method = Ctl_cli.click_method_arg
     and+ clickfinger_button_map =
       Ctl_cli.button_map_arg
         "clickfinger-button-map"
         ~doc:"Set the button order for clicks with one, two, or three fingers."
     and+ accel_profile = Ctl_cli.accel_profile_arg
     and+ accel_speed = Ctl_cli.accel_speed_arg
     and+ natural_scroll = Ctl_cli.natural_scroll_arg
     and+ left_handed = Ctl_cli.left_handed_arg
     and+ middle_emulation = Ctl_cli.middle_emulation_arg
     and+ scroll_method = Ctl_cli.scroll_method_arg
     and+ send_events = Ctl_cli.send_events_arg
     and+ scroll_factor = Ctl_cli.scroll_factor_arg in
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
     else Ok (Command.Input (Rule_add (Touchpad { name; case; settings })))
;;

let name = "touchpad"
let doc = "Add or update a touchpad rule"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
