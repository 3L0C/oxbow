let set_repeat (wm : Types.Window_manager.t) ~(rate : int) ~(delay : int) =
  wm.config.repeat_rate <- rate;
  wm.config.repeat_delay <- delay;
  List.iter
    (fun (e : Types.Keyboard.t) ->
       match e.kind with
       | Some River.Input_management.River_input_device_v1.Type.Keyboard ->
         River.Input_management.River_input_device_v1.set_repeat_info
           e.device
           ~rate:(Int32.of_int rate)
           ~delay:(Int32.of_int delay)
       | _ -> ())
    wm.input_devices
;;

let set_layout_file (wm : Types.Window_manager.t) ~(path : string) =
  match Unix.openfile path [ O_RDONLY ] 0 with
  | exception Unix.Unix_error (e, _, _) ->
    Error (Printf.sprintf "open %s: %s" path (Unix.error_message e))
  | fd ->
    wm.desired_keymap_path <- Some path;
    let request_path = path in
    let _keymap =
      River.Xkb_config.River_xkb_config_v1.create_keymap
        wm.river_xkb_config_v1
        object
          inherit [_] River.Xkb_config.River_xkb_keymap_v1.v1

          method on_success proxy =
            let self = Wayland.Proxy.cast_version proxy in
            match wm.desired_keymap_path with
            | Some p when String.equal p request_path ->
              let old = wm.current_keymap in
              wm.current_keymap <- Some self;
              List.iter
                (fun (k : Types.Keyboard.t) ->
                   match k.kind with
                   | Some River.Input_management.River_input_device_v1.Type.Keyboard ->
                     Option.iter
                       (fun xkb ->
                          River.Xkb_config.River_xkb_keyboard_v1.set_keymap
                            xkb
                            ~keymap:self)
                       k.xkb
                   | _ -> ())
                wm.input_devices;
              Option.iter River.Xkb_config.River_xkb_keymap_v1.destroy old
            | _ -> River.Xkb_config.River_xkb_keymap_v1.destroy self

          method on_failure self ~error_msg =
            (Logs.warn @@ fun m -> m "keymap %s rejected: %s" request_path error_msg);
            River.Xkb_config.River_xkb_keymap_v1.destroy self
        end
        ~fd
        ~format:River.Xkb_config.River_xkb_config_v1.Keymap_format.Text_v1
    in
    Unix.close fd;
    Ok ()
;;
