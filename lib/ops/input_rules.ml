open! Oxbow_core
open! Oxbow_state

let ( |>? ) o f = Option.iter f o

let apply_touchpad obj dev ~device (settings : Input_rule.Touchpad.t) =
  settings.tap |>? Emit.set_tap dev ~device;
  (settings.tap_button_map
   |>? function
   | Lrm -> Emit.set_tap_button_map dev ~device Wire.Libinput.Tap_button_map.Lrm
   | Lmr -> Emit.set_tap_button_map dev ~device Wire.Libinput.Tap_button_map.Lmr);
  settings.drag |>? Emit.set_drag dev ~device;
  (settings.drag_lock
   |>? function
   | Disabled -> Emit.set_drag_lock dev ~device Wire.Libinput.Drag_lock_state.Disabled
   | Enabled_timeout ->
     Emit.set_drag_lock dev ~device Wire.Libinput.Drag_lock_state.Enabled_timeout
   | Enabled_sticky ->
     Emit.set_drag_lock dev ~device Wire.Libinput.Drag_lock_state.Enabled_sticky);
  (settings.three_finger_drag
   |>? function
   | Disabled ->
     Emit.set_three_finger_drag dev ~device Wire.Libinput.Three_finger_drag_state.Disabled
   | Enabled_3fg ->
     Emit.set_three_finger_drag
       dev
       ~device
       Wire.Libinput.Three_finger_drag_state.Enabled_3fg
   | Enabled_4fg ->
     Emit.set_three_finger_drag
       dev
       ~device
       Wire.Libinput.Three_finger_drag_state.Enabled_4fg);
  settings.dwt |>? Emit.set_dwt dev ~device;
  settings.dwtp |>? Emit.set_dwtp dev ~device;
  (settings.click_method
   |>? function
   | None -> Emit.set_click_method dev ~device Wire.Libinput.Click_method.None
   | Button_areas ->
     Emit.set_click_method dev ~device Wire.Libinput.Click_method.Button_areas
   | Clickfinger ->
     Emit.set_click_method dev ~device Wire.Libinput.Click_method.Clickfinger);
  (settings.clickfinger_button_map
   |>? function
   | Lrm ->
     Emit.set_clickfinger_button_map dev ~device Wire.Libinput.Clickfinger_button_map.Lrm
   | Lmr ->
     Emit.set_clickfinger_button_map dev ~device Wire.Libinput.Clickfinger_button_map.Lmr
  );
  (settings.accel_profile
   |>? function
   | None -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.None
   | Flat -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.Flat
   | Adaptive -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.Adaptive
   | Custom -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.Custom);
  settings.accel_speed |>? Emit.set_accel_speed dev ~device;
  settings.natural_scroll |>? Emit.set_natural_scroll dev ~device;
  settings.left_handed |>? Emit.set_left_handed dev ~device;
  settings.middle_emulation |>? Emit.set_middle_emulation dev ~device;
  (settings.scroll_method
   |>? function
   | No_scroll -> Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.No_scroll
   | Two_finger ->
     Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.Two_finger
   | Edge -> Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.Edge
   | On_button_down ->
     Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.On_button_down);
  (settings.send_events
   |>? function
   | Enabled -> Emit.set_send_events dev ~device Wire.Libinput.Send_events_modes.enabled
   | Disabled -> Emit.set_send_events dev ~device Wire.Libinput.Send_events_modes.disabled
   | Disabled_on_external_mouse ->
     Emit.set_send_events
       dev
       ~device
       Wire.Libinput.Send_events_modes.disabled_on_external_mouse);
  settings.scroll_factor |>? Emit.set_scroll_factor obj
;;

let apply_mouse obj dev ~device (settings : Input_rule.Mouse.t) =
  (settings.accel_profile
   |>? function
   | None -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.None
   | Flat -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.Flat
   | Adaptive -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.Adaptive
   | Custom -> Emit.set_accel_profile dev ~device Wire.Libinput.Accel_profile.Custom);
  settings.accel_speed |>? Emit.set_accel_speed dev ~device;
  settings.natural_scroll |>? Emit.set_natural_scroll dev ~device;
  settings.left_handed |>? Emit.set_left_handed dev ~device;
  settings.middle_emulation |>? Emit.set_middle_emulation dev ~device;
  (settings.scroll_method
   |>? function
   | No_scroll -> Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.No_scroll
   | Two_finger ->
     Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.Two_finger
   | Edge -> Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.Edge
   | On_button_down ->
     Emit.set_scroll_method dev ~device Wire.Libinput.Scroll_method.On_button_down);
  (settings.scroll_button
   |>? fun pb -> Pointer_button.to_int32 pb |> Emit.set_scroll_button dev ~device);
  settings.scroll_button_lock |>? Emit.set_scroll_button_lock dev ~device;
  (settings.send_events
   |>? function
   | Enabled -> Emit.set_send_events dev ~device Wire.Libinput.Send_events_modes.enabled
   | Disabled -> Emit.set_send_events dev ~device Wire.Libinput.Send_events_modes.disabled
   | Disabled_on_external_mouse ->
     Emit.set_send_events
       dev
       ~device
       Wire.Libinput.Send_events_modes.disabled_on_external_mouse);
  settings.scroll_factor |>? Emit.set_scroll_factor obj
;;

let apply (wm : Wm.t) (device : Input_device.t) =
  match device.lifecycle, device.libinput, device.role with
  | (New | Removed), _, _ | _, None, _ -> ()
  | Active, Some dev, Pointer { class_ = Touchpad } ->
    let settings =
      List.fold_left
        (fun acc (rule : Input_rule.t) ->
           match rule with
           | Touchpad r when Input_rule.name_matches r ~name:device.name ->
             Input_rule.Touchpad.merge ~old:acc ~new_:r.settings
           | _ -> acc)
        Input_rule.Touchpad.empty
        wm.config.rules.input
    in
    apply_touchpad device.obj dev ~device:device.name settings
  | Active, Some dev, Pointer { class_ = Mouse } ->
    let settings =
      List.fold_left
        (fun acc (rule : Input_rule.t) ->
           match rule with
           | Mouse r when Input_rule.name_matches r ~name:device.name ->
             Input_rule.Mouse.merge ~old:acc ~new_:r.settings
           | _ -> acc)
        Input_rule.Mouse.empty
        wm.config.rules.input
    in
    apply_mouse device.obj dev ~device:device.name settings
  | Active, _, (Keyboard _ | Touch | Tablet) -> ()
;;

let apply_all wm = List.iter (apply wm) wm.input_devices

let add (wm : Wm.t) (rule : Input_rule.t) =
  let rule' = List.find_opt (Input_rule.equal rule) wm.config.rules.input in
  match rule', rule with
  | Some (Touchpad { settings = old; pattern; case }), Touchpad { settings = new_; _ } ->
    let merged_rule =
      Input_rule.Touchpad
        { pattern; case; settings = Input_rule.Touchpad.merge ~old ~new_ }
    in
    Config.replace_input_rule wm merged_rule;
    apply_all wm;
    Ok None
  | Some (Mouse { settings = old; pattern; case }), Mouse { settings = new_; _ } ->
    let merged_rule =
      Input_rule.Mouse { pattern; case; settings = Input_rule.Mouse.merge ~old ~new_ }
    in
    Config.replace_input_rule wm merged_rule;
    apply_all wm;
    Ok None
  | Some (Touchpad _), Mouse _ | Some (Mouse _), Touchpad _ ->
    Error "mismatched rules returned as equal; please open an issue"
  | None, _ ->
    Config.add_input_rule wm rule;
    apply_all wm;
    Ok None
;;

let remove (wm : Wm.t) index =
  match List.nth_opt wm.config.rules.input index with
  | None -> Error (Printf.sprintf "no input rule at index %d" index)
  | Some _ ->
    Config.remove_input_rule wm index;
    Ok None
;;
