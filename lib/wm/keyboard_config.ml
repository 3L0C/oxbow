module Rinput = Ocdwm_protocol.River_input_management_v1_client
module Rxkb = Ocdwm_protocol.River_xkb_config_v1_client

let set_repeat (wm : Types.Window_manager.t) ~(rate : int) ~(delay : int) =
  wm.config.repeat_rate <- rate;
  wm.config.repeat_delay <- delay;
  List.iter
    (fun (e : Types.Keyboard.t) ->
       match e.kind with
       | Some Rinput.River_input_device_v1.Type.Keyboard ->
         Rinput.River_input_device_v1.set_repeat_info
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
      Rxkb.River_xkb_config_v1.create_keymap
        wm.river_xkb_config_v1
        object
          inherit [_] Rxkb.River_xkb_keymap_v1.v2

          method on_success self =
            match wm.desired_keymap_path with
            | Some p when String.equal p request_path ->
              let old = wm.current_keymap in
              wm.current_keymap <- Some self;
              List.iter
                (fun (k : Types.Keyboard.t) ->
                   match k.kind with
                   | Some Rinput.River_input_device_v1.Type.Keyboard ->
                     Option.iter
                       (fun xkb -> Rxkb.River_xkb_keyboard_v1.set_keymap xkb ~keymap:self)
                       k.xkb
                   | _ -> ())
                wm.input_devices;
              Option.iter Rxkb.River_xkb_keymap_v1.destroy old
            | _ -> Rxkb.River_xkb_keymap_v1.destroy self

          method on_failure self ~error_msg =
            (Logs.warn @@ fun m -> m "keymap %s rejected: %s" request_path error_msg);
            Rxkb.River_xkb_keymap_v1.destroy self
        end
        ~fd
        ~format:Rxkb.River_xkb_config_v1.Keymap_format.Text_v1
    in
    Unix.close fd;
    Ok ()
;;
