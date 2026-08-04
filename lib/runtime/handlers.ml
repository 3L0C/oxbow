open! Oxbow_core
open! Oxbow_state
open! Oxbow_ops

let registry : Wayland.Registry.t option ref = ref None

let with_registry f =
  match !registry with
  | None -> Logs.err @@ fun m -> m "no registry defined!!!"
  | Some r -> f r
;;

let on_finished (wm_box : Wm.t Box.t) =
  match wm_box.body with
  | None -> ()
  | Some wm -> Lifecycle.notify_finished wm
;;

let on_manage_start proxy (wm_box : Wm.t Box.t) =
  match wm_box.body with
  | Some wm -> Cycle.manage wm proxy
  | None -> ()
;;

let on_output _ river_output (wm_box : Wm.t Box.t) =
  with_registry
  @@ fun registry ->
  let wm = Option.get wm_box.body in
  let output_box : Output.t Box.t = { body = None } in
  let layer_shell =
    River.Layer_shell.River_layer_shell_v1.get_output wm.river_lsh_v1 ~output:river_output
    @@ object
         inherit [_] River.Layer_shell.River_layer_shell_output_v1.v1

         method on_non_exclusive_area _ ~x ~y ~width ~height =
           match output_box.body with
           | Some o ->
             Output.set_usable o
             @@ Int32.{ x = to_int x; y = to_int y; w = to_int width; h = to_int height }
           | None -> ()
       end
  in
  let output : Output.t =
    { obj = river_output
    ; layer_shell
    ; lifecycle = Active
    ; name = None
    ; geom = { x = 0l; y = 0l; w = 0l; h = 0l }
    ; usable = { x = 0; y = 0; w = 0; h = 0 }
    ; tags = { selected = Tag.Set.singleton 1; previous = Tag.Set.singleton 1 }
    ; overview = { offset = 0; enabled = false; gaps = 10; head = None }
    ; tag_data =
        Array.init 32 (fun _ -> Config.copy_tag_data wm.config.default_tag_config)
    ; focus_stack = []
    ; wm_stack = []
    }
  in
  let sync_usable () =
    if output.usable.w = 0 || output.usable.h = 0
    then Rect.to_int output.geom |> Output.set_usable output
  in
  Box.fill output_box output;
  Wayland.Proxy.Handler.attach
    river_output
    object
      inherit [_] River.Window_management.River_output_v1.v4
      method on_removed _ = Output.set_lifecycle output Removed

      method on_wl_output _ ~name =
        let _ =
          Wayland.Wayland_client.Wl_registry.bind
            (Wayland.Registry.wl_registry registry)
            ~name
          @@ ( object
                 inherit [_] Wayland.Wayland_client.Wl_output.v4

                 method on_name _ ~name =
                   Output.set_name output @@ Some name;
                   List.iter (fun w -> Window.rehome w name) wm.windows

                 method on_scale _ ~factor:_ = ()
                 method on_mode _ ~flags:_ ~width:_ ~height:_ ~refresh:_ = ()

                 method on_geometry
                   _
                   ~x:_
                   ~y:_
                   ~physical_width:_
                   ~physical_height:_
                   ~subpixel:_
                   ~make:_
                   ~model:_
                   ~transform:_ =
                   ()

                 method on_done _ = ()
                 method on_description _ ~description:_ = ()
               end
             , 4l )
        in
        ()

      method on_position _ ~x ~y =
        Output.set_geom output { x; y; w = output.geom.w; h = output.geom.h };
        sync_usable ()

      method on_dimensions _ ~width ~height =
        Output.set_geom
          output
          { x = output.geom.x; y = output.geom.y; w = width; h = height };
        sync_usable ()

      (* TODO capture this data for reporting *)
      method on_capture_sessions _ ~count:_ = ()
    end;
  Wm.set_outputs wm (output :: wm.outputs);
  List.iter (Wm.ensure_seat_output wm) wm.seats
;;

let on_render_start proxy (wm_box : Wm.t Box.t) =
  match wm_box.body with
  | Some wm -> Cycle.render wm proxy
  | None -> ()
;;

let on_seat _ river_seat (wm_box : Wm.t Box.t) =
  with_registry
  @@ fun registry ->
  let wm = Option.get wm_box.body in
  let seat_box : Seat.t Box.t = { body = None } in
  let layer_shell =
    River.Layer_shell.River_layer_shell_v1.get_seat wm.river_lsh_v1 ~seat:river_seat
    @@ object
         inherit [_] River.Layer_shell.River_layer_shell_seat_v1.v1

         method on_focus_none _ =
           Option.iter (fun s -> Seat.set_layer_focus s None) seat_box.body

         method on_focus_non_exclusive _ =
           Option.iter
             (fun s -> Seat.set_layer_focus s @@ Some Non_exclusive)
             seat_box.body

         method on_focus_exclusive _ =
           Option.iter (fun s -> Seat.set_layer_focus s @@ Some Exclusive) seat_box.body
       end
  in
  let seat : Seat.t =
    { obj = river_seat
    ; layer_shell
    ; xkb_seat =
        Emit.create_xkb_bindings_seat
          wm.river_xkb_v1
          ~seat:river_seat
          ~on_modifiers_update:(fun ~old:_ ~new_ ->
            Option.iter
              (fun (s : Seat.t) ->
                 if s.overview_watch <> 0l && Int32.logand new_ s.overview_watch = 0l
                 then (
                   s.overview_watch <- 0l;
                   Option.iter Arrange.exit_overview s.output))
              seat_box.body)
    ; overview_watch = 0l
    ; watch_sent = 0l
    ; lifecycle = New
    ; name = None
    ; output = None
    ; focus_cleared = false
    ; position = { x = 0l; y = 0l }
    ; layer_focus = None
    ; mode = Mode.normal
    ; xkb_bindings = []
    ; pointer_bindings = []
    ; pending_requests = Queue.create ()
    ; hovered = None
    ; interacted = None
    ; warp_request = No_request
    ; focus_state = Idle
    ; cursor_target = None
    ; op = None
    }
  in
  Box.fill seat_box seat;
  Wayland.Proxy.Handler.attach
    river_seat
    object
      inherit [_] River.Window_management.River_seat_v1.v4
      method on_removed _ = Seat.set_lifecycle seat Closing

      method on_pointer_enter _ ~window =
        match Wm.find_window_opt wm @@ Wayland.Proxy.id window with
        | Some w -> Seat.set_hovered seat @@ Some w
        | None -> ()

      method on_pointer_leave _ = Seat.set_hovered seat None

      method on_window_interaction _ ~window =
        match Wm.find_window_opt wm @@ Wayland.Proxy.id window with
        | Some w -> Seat.set_interacted seat @@ Some w
        | None -> ()

      method on_op_delta _ ~dx ~dy = Seat.set_op_delta seat dx dy
      method on_op_release _ = Seat.release_op seat

      method on_wl_seat _ ~name =
        let _ =
          Wayland.Wayland_client.Wl_registry.bind
            (Wayland.Registry.wl_registry registry)
            ~name
          @@ ( object
                 inherit [_] Wayland.Wayland_client.Wl_seat.v9
                 method on_name _ ~name = Seat.set_name seat @@ Some name
                 method on_capabilities _ ~capabilities:_ = ()
               end
             , 9l )
        in
        ()

      method on_shell_surface_interaction _ ~shell_surface:_ = ()
      method on_pointer_position _ ~x ~y = Pointer.handle_position wm seat (x, y)
    end;
  Wm.set_seats wm (seat :: wm.seats);
  if Option.is_none wm.primary_seat then Wm.set_primary_seat wm @@ Some seat;
  Wm.ensure_seat_output wm seat
;;

let on_session_locked _proxy (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  Wm.set_session_locked wm true;
  Schedule.manage ()
;;

let on_session_unlocked _proxy (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  Wm.set_session_locked wm false;
  Schedule.manage ()
;;

let on_unavailable _proxy =
  Printf.eprintf "error: another window manager is already running\n";
  raise Exceptions.Unavailable
;;

let on_window _ river_window (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let scroll_width =
    match Wm.default_output wm with
    | None -> wm.config.default_tag_config.scrolling.default_width
    | Some o -> (Output.to_tag_data o).scrolling.default_width
  in
  let output = Wm.default_output wm in
  let window = Window.create output scroll_width river_window in
  Wayland.Proxy.Handler.attach
    river_window
    object
      inherit [_] River.Window_management.River_window_v1.v4
      method on_closed _ = Window.set_lifecycle window Closing

      method on_dimensions _ ~width ~height =
        if window.geom.w <> width || window.geom.h <> height
        then
          if Output.arranges window
          then (
            Logs.warn (fun m ->
              m
                "%s client changed size while tiled"
                (Option.value ~default:"?" window.app_id));
            Window.reject_dimensions window ~width ~height)
          else Window.queue_request window @@ Dimensions { width; height }
        else Window.set_defense window Idle

      method on_unreliable_pid _ ~unreliable_pid =
        Window.set_unreliable_pid window @@ Some unreliable_pid

      method on_parent _ ~parent =
        let set_parent p = Window.set_parent window ~parent:p in
        Option.bind parent (fun p -> Wm.find_window_opt wm @@ Wayland.Proxy.id p)
        |> set_parent

      method on_title _ ~title = Window.set_title window title
      method on_identifier _ ~identifier = Window.set_identifier window @@ Some identifier

      method on_dimensions_hint _ ~min_width ~min_height ~max_width ~max_height =
        Window.set_is_fixed
          window
          (min_width > 0l
           && min_height > 0l
           && min_width = max_width
           && min_height = max_height);
        Window.set_size_hints
          window
          { min_w = min_width; max_w = max_width; min_h = min_height; max_h = max_height }

      method on_decoration_hint _ ~hint =
        Window.Decoration_hint.(
          Window.set_decoration_hint window
          @@ Some
               (match hint with
                | Only_supports_csd -> Only_csd
                | Prefers_csd -> Prefer_csd
                | Prefers_ssd -> Prefer_ssd
                | No_preference -> No_preference))

      method on_app_id _ ~app_id = Window.set_app_id window app_id

      method on_pointer_move_requested _ ~seat =
        match Wm.find_seat_opt wm @@ Wayland.Proxy.id seat with
        | Some s -> Window.queue_request window @@ Move { seat = s }
        | None -> ()

      method on_pointer_resize_requested _ ~seat ~edges =
        match Wm.find_seat_opt wm @@ Wayland.Proxy.id seat with
        | Some s -> Window.queue_request window @@ Resize { seat = s; edges }
        | None -> ()

      method on_maximize_requested _ = ()
      method on_unmaximize_requested _ = ()

      method on_fullscreen_requested _ ~output =
        let queue_request o = Window.queue_request window @@ Fullscreen { output = o } in
        Option.bind output (fun o -> Wm.find_output_opt wm @@ Wayland.Proxy.id o)
        |> queue_request

      method on_exit_fullscreen_requested _ = Window.queue_request window Exit_fullscreen

      method on_presentation_hint _ ~hint =
        Window.set_presentation_hint window @@ Some hint

      method on_show_window_menu_requested _ ~x:_ ~y:_ = ()
      method on_minimize_requested _ = ()

      (* TODO capture this data and maybe add border color variant for recorded windows? *)
      method on_capture_sessions _ ~count:_ = ()
    end;
  Wm.set_windows wm (window :: wm.windows)
;;

let on_input_device proxy (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let device_kind : River.Proto.Input.Management.River_input_device_v1.Type.t option ref =
    ref None
  in
  let device_name = ref "" in
  let device_box : Input_device.t Box.t = { body = None } in
  let resolve_device device =
    Box.fill device_box device;
    Wm.add_input_device wm device
  in
  let make role =
    let device =
      Input_device.
        { obj = proxy; name = !device_name; role; lifecycle = New; libinput = None }
    in
    resolve_device device;
    device
  in
  Wayland.Proxy.Handler.attach proxy
  @@ object
       inherit [_] River.Input.Management.River_input_device_v1.v1
       method on_type _ ~type_ = device_kind := Some type_
       method on_name _ ~name = device_name := name

       method on_done _ =
         if Option.is_none device_box.body
         then (
           match !device_kind with
           | Some Keyboard ->
             let keyboard = Wm.find_xkb_stash_opt wm @@ Wayland.Proxy.id proxy in
             let device = make (Keyboard { keyboard }) in
             Emit.set_repeat_info
               proxy
               ~rate:(Int32.of_int wm.config.repeat_rate)
               ~delay:(Int32.of_int wm.config.repeat_delay);
             Option.iter (Input_device.set_keyboard wm device) keyboard
           | Some Pointer -> ignore @@ make (Pointer { class_ = Mouse })
           | Some Touch -> ignore @@ make Touch
           | Some Tablet -> ignore @@ make Tablet
           | None -> Logs.err @@ fun m -> m "input device sent 'done' without a type")

       method on_removed _ =
         match device_box.body with
         | Some device -> Wm.remove_input_device wm device
         | None -> Emit.destroy_input_device proxy
     end
;;

let on_libinput_device device (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let device_box : Input_device.t Box.t = { body = None } in
  Wayland.Proxy.Handler.attach device
  @@ object
       inherit [_] River.Input.Config.River_libinput_device_v1.v2

       method on_input_device _ ~device:paired =
         match Wm.find_input_device_opt wm (Wayland.Proxy.id paired) with
         | None -> Logs.warn @@ fun m -> m "input device unknown"
         | Some d ->
           Box.fill device_box d;
           d.libinput <- Some device

       method on_tap_support _ ~finger_count =
         Option.iter
           (fun (d : Input_device.t) ->
              if finger_count > 0l
              then (
                match d.role with
                | Pointer p -> p.class_ <- Touchpad
                | r ->
                  Logs.err
                  @@ fun m ->
                  m
                    "got tap support on a non-pointer device: %s"
                    (Input_device.role_to_string r)))
           device_box.body

       method on_done _ =
         Option.iter
           (fun (d : Input_device.t) ->
              if d.lifecycle = New
              then (
                Input_device.set_lifecycle d Active;
                Input_rules.apply wm d))
           device_box.body

       method on_removed _ =
         Option.iter
           (fun (d : Input_device.t) ->
              d.libinput <- None;
              Emit.destroy_libinput_device device)
           device_box.body

       method on_three_finger_drag_support _ ~finger_count:_ = ()
       method on_three_finger_drag_default _ ~state:_ = ()
       method on_three_finger_drag_current _ ~state:_ = ()
       method on_tap_default _ ~state:_ = ()
       method on_tap_current _ ~state:_ = ()
       method on_tap_button_map_default _ ~button_map:_ = ()
       method on_tap_button_map_current _ ~button_map:_ = ()
       method on_send_events_support _ ~modes:_ = ()
       method on_send_events_default _ ~mode:_ = ()
       method on_send_events_current _ ~mode:_ = ()
       method on_scroll_method_support _ ~methods:_ = ()
       method on_scroll_method_default _ ~method_:_ = ()
       method on_scroll_method_current _ ~method_:_ = ()
       method on_scroll_button_lock_default _ ~state:_ = ()
       method on_scroll_button_lock_current _ ~state:_ = ()
       method on_scroll_button_default _ ~button:_ = ()
       method on_scroll_button_current _ ~button:_ = ()
       method on_rotation_support _ ~supported:_ = ()
       method on_rotation_default _ ~angle:_ = ()
       method on_rotation_current _ ~angle:_ = ()
       method on_natural_scroll_support _ ~supported:_ = ()
       method on_natural_scroll_default _ ~state:_ = ()
       method on_natural_scroll_current _ ~state:_ = ()
       method on_middle_emulation_support _ ~supported:_ = ()
       method on_middle_emulation_default _ ~state:_ = ()
       method on_middle_emulation_current _ ~state:_ = ()
       method on_left_handed_support _ ~supported:_ = ()
       method on_left_handed_default _ ~state:_ = ()
       method on_left_handed_current _ ~state:_ = ()
       method on_dwtp_support _ ~supported:_ = ()
       method on_dwtp_default _ ~state:_ = ()
       method on_dwtp_current _ ~state:_ = ()
       method on_dwt_support _ ~supported:_ = ()
       method on_dwt_default _ ~state:_ = ()
       method on_dwt_current _ ~state:_ = ()
       method on_drag_lock_default _ ~state:_ = ()
       method on_drag_lock_current _ ~state:_ = ()
       method on_drag_default _ ~state:_ = ()
       method on_drag_current _ ~state:_ = ()
       method on_clickfinger_button_map_default _ ~button_map:_ = ()
       method on_clickfinger_button_map_current _ ~button_map:_ = ()
       method on_click_method_support _ ~methods:_ = ()
       method on_click_method_default _ ~method_:_ = ()
       method on_click_method_current _ ~method_:_ = ()
       method on_calibration_matrix_support _ ~supported:_ = ()
       method on_calibration_matrix_default _ ~matrix:_ = ()
       method on_calibration_matrix_current _ ~matrix:_ = ()
       method on_accel_speed_default _ ~speed:_ = ()
       method on_accel_speed_current _ ~speed:_ = ()
       method on_accel_profiles_support _ ~profiles:_ = ()
       method on_accel_profile_default _ ~profile:_ = ()
       method on_accel_profile_current _ ~profile:_ = ()
     end
;;

let on_xkb_keyboard keyboard (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let device_ref : int32 option ref = ref None in
  Wayland.Proxy.Handler.attach keyboard
  @@ object
       inherit [_] River.Xkb.Config.River_xkb_keyboard_v1.v1

       method on_input_device _ ~device =
         let d = Wayland.Proxy.id device in
         device_ref := Some d;
         match Wm.find_input_device_opt wm d with
         | None ->
           Wm.add_xkb_stash wm d keyboard;
           Logs.warn @@ fun m -> m "xkb keyboard for unknown device"
         | Some entry -> Input_device.set_keyboard wm entry keyboard

       method on_removed _ =
         Emit.destroy_xkb_keyboard keyboard;
         match !device_ref with
         | Some device ->
           (match Wm.find_input_device_opt wm device with
            | Some d -> Input_device.clear_device d keyboard
            | None -> Wm.remove_xkb_stash wm device)
         | None -> ()

       method on_numlock_enabled _ = ()
       method on_numlock_disabled _ = ()
       method on_layout _ ~index:_ ~name:_ = ()
       method on_done _ = ()
       method on_capslock_enabled _ = ()
       method on_capslock_disabled _ = ()
     end
;;
