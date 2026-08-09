open! Oxbow_state
open! Oxbow_ipc

let set_repeat_info wm ~rate ~delay =
  Config.set_key_repeat wm ~rate ~delay;
  List.iter
    (fun (d : Input_device.t) ->
       match d.role with
       | Keyboard _ ->
         Emit.set_repeat_info d.obj ~rate:(Int32.of_int rate) ~delay:(Int32.of_int delay)
       | _ -> ())
    wm.input_devices
;;

let set_layout_file wm ~path =
  match Unix.openfile path [ O_RDONLY ] 0 with
  | exception Unix.Unix_error (e, _, _) ->
    Error (Printf.sprintf "open %s: %s" path (Unix.error_message e))
  | fd ->
    Wm.set_desired_keymap_path wm @@ Some path;
    let request_path = path in
    let _keymap =
      River.Xkb.Config.River_xkb_config_v1.create_keymap
        wm.river_xkb_config_v1
        object
          inherit [_] River.Obj.Xkb.Config.Client.keymap

          method on_success proxy =
            let self = Wayland.Proxy.cast_version proxy in
            match wm.desired_keymap_path with
            | Some p when String.equal p request_path ->
              let old = wm.keymap in
              Wm.set_keymap wm @@ Some self;
              List.iter
                (fun (d : Input_device.t) ->
                   match d.role with
                   | Keyboard k ->
                     Option.iter
                       (fun xkb ->
                          River.Xkb.Config.River_xkb_keyboard_v1.set_keymap
                            xkb
                            ~keymap:self)
                       k.keyboard
                   | _ -> ())
                wm.input_devices;
              Option.iter River.Xkb.Config.River_xkb_keymap_v1.destroy old
            | _ -> River.Xkb.Config.River_xkb_keymap_v1.destroy self

          method on_failure self ~error_msg =
            (Logs.warn @@ fun m -> m "keymap %s rejected: %s" request_path error_msg);
            River.Xkb.Config.River_xkb_keymap_v1.destroy self
        end
        ~fd
        ~format:River.Xkb.Config.River_xkb_config_v1.Keymap_format.Text_v1
    in
    Unix.close fd;
    Ok None
;;

let handle (ctx : Ctx.manage Ctx.t) _seat (cmd : Command.Input.Keyboard.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Repeat { rate; delay } ->
    set_repeat_info wm ~rate ~delay;
    Ok None
  | Layout_file path -> set_layout_file wm ~path
;;
