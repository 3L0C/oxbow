open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ops

type (_, _) Wayland.S.user_data +=
  | Seat_box of Seat.t Box.t
  | Seat_data of Seat.t
  | Output_box of Output.t Box.t
  | Output_data of Output.t
  | Window_data of Window.t

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
  let wm = Option.get wm_box.body in
  let output_box : Output.t Box.t = { body = None } in
  let layer_shell =
    River.Layer_shell.River_layer_shell_v1.get_output wm.river_lsh_v1 ~output:river_output
    @@ object
         inherit [_] River.Layer_shell.River_layer_shell_output_v1.v1
         method user_data = Output_box output_box

         method on_non_exclusive_area proxy ~x ~y ~width ~height =
           match Wayland.Proxy.user_data proxy with
           | Output_box { body = Some o } ->
             Output.set_usable o
             @@ Int32.{ x = to_int x; y = to_int y; w = to_int width; h = to_int height }
           | _ -> assert false
       end
  in
  let output : Output.t =
    { obj = river_output
    ; layer_shell
    ; lifecycle = Active
    ; name = None
    ; geom = { x = 0l; y = 0l; w = 0l; h = 0l }
    ; usable = { x = 0; y = 0; w = 0; h = 0 }
    ; selected_tags = Tag.Set.singleton 1
    ; previous_tags = Tag.Set.singleton 1
    ; arrangement = Tiling
    ; scroll_offset = 0
    ; tag_data =
        Array.init 32 (fun _ -> Config.create_tag_data wm.config.default_tag_config.entry)
    ; focus_stack = []
    ; wm_stack = []
    }
  in
  Box.fill output_box output;
  Wayland.Proxy.Handler.attach
    river_output
    object
      inherit [_] River.Window_management.River_output_v1.v4
      method user_data = Output_data output
      method on_removed _ = Output.set_lifecycle output Removed

      method on_wl_output _ ~name =
        let _ =
          Wayland.Wayland_client.Wl_registry.bind
            (Wayland.Registry.wl_registry wm.registry)
            ~name
          @@ ( object
                 inherit [_] Wayland.Wayland_client.Wl_output.v4

                 method on_name _ ~name =
                   Output.set_name output @@ Some name;
                   List.iter (fun w -> Window.rehome wm w name) wm.windows

                 method on_scale _ ~factor = ()
                 method on_mode _ ~flags ~width ~height ~refresh = ()

                 method on_geometry
                   _
                   ~x
                   ~y
                   ~physical_width
                   ~physical_height
                   ~subpixel
                   ~make
                   ~model
                   ~transform =
                   ()

                 method on_done _ = ()
                 method on_description _ ~description = ()
               end
             , 4l )
        in
        ()

      method on_position _ ~x ~y =
        Output.set_geom output { x; y; w = output.geom.w; h = output.geom.h };
        if output.usable.w = 0 || output.usable.h = 0
        then
          Output.set_usable output
          @@ Int32.
               { x = to_int output.geom.x
               ; y = to_int output.geom.y
               ; w = to_int output.geom.w
               ; h = to_int output.geom.h
               }

      method on_dimensions _ ~width ~height =
        Output.set_geom
          output
          { x = output.geom.x; y = output.geom.y; w = width; h = height };
        if output.usable.w = 0 || output.usable.h = 0
        then
          Output.set_usable output
          @@ Int32.
               { x = to_int output.geom.x
               ; y = to_int output.geom.y
               ; w = to_int output.geom.w
               ; h = to_int output.geom.h
               }
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
  let wm = Option.get wm_box.body in
  let seat_box : Seat.t Box.t = { body = None } in
  let layer_shell =
    River.Layer_shell.River_layer_shell_v1.get_seat wm.river_lsh_v1 ~seat:river_seat
    @@ object
         inherit [_] River.Layer_shell.River_layer_shell_seat_v1.v1
         method user_data = Seat_box seat_box

         method on_focus_none proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Seat_box { body = Some s } -> s
             | _ -> invalid_arg "Missing seat data."
           in
           Seat.set_layer_focus s None

         method on_focus_non_exclusive proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Seat_box { body = Some s } -> s
             | _ -> invalid_arg "Missing seat data."
           in
           Seat.set_layer_focus s @@ Some Non_exclusive

         method on_focus_exclusive proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Seat_box { body = Some s } -> s
             | _ -> invalid_arg "Missing seat data."
           in
           Seat.set_layer_focus s @@ Some Exclusive
       end
  in
  let seat : Seat.t =
    { obj = river_seat
    ; layer_shell
    ; lifecycle = New
    ; name = None
    ; output = None
    ; position = { x = 0l; y = 0l }
    ; layer_focus = None
    ; mode = Mode.normal
    ; xkb_bindings = []
    ; pointer_bindings = []
    ; pending_requests = Queue.create ()
    ; hovered = None
    ; interacted = None
    ; warp_pending = false
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
      method user_data = Seat_data seat
      method on_removed _ = Seat.set_lifecycle seat Closing

      method on_pointer_enter _ ~window =
        match Wayland.Proxy.user_data window with
        | Window_data w -> Seat.set_hovered seat @@ Some w
        | _ -> assert false

      method on_pointer_leave _ = Seat.set_hovered seat None

      method on_window_interaction _ ~window =
        match Wayland.Proxy.user_data window with
        | Window_data w -> Seat.set_interacted seat @@ Some w
        | _ -> assert false

      method on_op_delta _ ~dx ~dy = Seat.set_op_delta seat dx dy
      method on_op_release _ = Seat.release_op seat

      method on_wl_seat _ ~name =
        let _ =
          Wayland.Wayland_client.Wl_registry.bind
            (Wayland.Registry.wl_registry wm.registry)
            ~name
          @@ ( object
                 inherit [_] Wayland.Wayland_client.Wl_seat.v9

                 method on_name _ ~name =
                   (Logs.info @@ fun m -> m "Seat: Name: %S" name);
                   Seat.set_name seat @@ Some name

                 method on_capabilities _ ~capabilities = ()
               end
             , 9l )
        in
        ()

      method on_shell_surface_interaction _ ~shell_surface = ()
      method on_pointer_position _ ~x ~y = Pointer.handle_position wm seat ~x ~y
    end;
  Wm.set_seats wm (seat :: wm.seats);
  if Option.is_none wm.primary_seat then Wm.set_primary_seat wm @@ Some seat;
  Wm.ensure_seat_output wm seat
;;

let on_session_locked _proxy (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  Wm.set_session_locked wm true;
  Dirty.mark_wm wm
;;

let on_session_unlocked _proxy (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  Wm.set_session_locked wm false;
  Dirty.mark_wm wm
;;

let on_unavailable _proxy =
  Printf.eprintf "error: another window manager is already running\n";
  raise Exceptions.Unavailable
;;

let on_window _ river_window (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let window = Window.create (Wm.default_output wm) river_window in
  Wayland.Proxy.Handler.attach
    river_window
    object
      inherit [_] River.Window_management.River_window_v1.v4
      method user_data = Window_data window
      method on_closed _ = Window.set_lifecycle window Closing

      method on_dimensions _ ~width ~height =
        if window.geom.w <> width || window.geom.h <> height
        then (
          Option.iter Dirty.mark_output window.output;
          Window.queue_request wm window @@ Dimensions { width; height })

      method on_unreliable_pid _ ~unreliable_pid =
        Window.set_unreliable_pid window @@ Some unreliable_pid

      method on_parent _ ~parent = ()
      method on_title _ ~title = Window.set_title window title
      method on_identifier _ ~identifier = Window.set_identifier window @@ Some identifier

      method on_dimensions_hint _ ~min_width ~min_height ~max_width ~max_height =
        Window.set_is_fixed
          window
          Int32.(
            min_width > 0l
            && min_height > 0l
            && min_width = max_width
            && min_height = max_height);
        Window.set_size_hints
          window
          { min_w = min_width; max_w = max_width; min_h = min_height; max_h = max_height }

      method on_decoration_hint _ ~hint =
        River.Window_management.River_window_v1.Decoration_hint.(
          Window.set_decoration_hint window
          @@ Some
               (match hint with
                | Only_supports_csd -> Only_csd
                | Prefers_csd -> Prefer_csd
                | Prefers_ssd -> Prefer_ssd
                | No_preference -> No_preference))

      method on_app_id _ ~app_id = Window.set_app_id window app_id

      method on_pointer_move_requested _ ~seat =
        match Wayland.Proxy.user_data seat with
        | Seat_data s -> Window.queue_request wm window @@ Move { seat = s }
        | _ -> assert false

      method on_pointer_resize_requested _ ~seat ~edges =
        match Wayland.Proxy.user_data seat with
        | Seat_data s -> Window.queue_request wm window @@ Resize { seat = s; edges }
        | _ -> assert false

      method on_maximize_requested _ = Window.queue_request wm window Maximize
      method on_unmaximize_requested _ = Window.queue_request wm window Unmaximize

      method on_fullscreen_requested _ ~output =
        match output with
        | Some o ->
          (match Wayland.Proxy.user_data o with
           | Output_data o ->
             Window.queue_request wm window @@ Fullscreen { output = Some o }
           | _ -> assert false)
        | None -> Window.queue_request wm window @@ Fullscreen { output = None }

      method on_exit_fullscreen_requested _ =
        Window.queue_request wm window Exit_fullscreen

      method on_presentation_hint _ ~hint =
        Window.set_presentation_hint window @@ Some hint

      method on_show_window_menu_requested _ ~x ~y = ()
      method on_minimize_requested _ = ()
    end;
  Wm.set_windows wm (window :: wm.windows)
;;

let on_input_device device (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let entry_kind : Input_device.Kind.t option ref = ref None in
  let entry_name = ref "" in
  let entry_box : Input_device.t Box.t = { body = None } in
  let resolve_entry entry =
    Box.fill entry_box entry;
    Wm.add_input_device wm entry
  in
  Wayland.Proxy.Handler.attach device
  @@ object
       inherit [_] River.Input_management.River_input_device_v1.v1
       method on_type _ ~type_ = entry_kind := Some type_
       method on_name _ ~name = entry_name := name

       method on_done _ =
         if Option.is_none entry_box.body
         then (
           match !entry_kind with
           | Some Keyboard ->
             let xkb = Wm.find_xkb_stash_opt wm @@ Wayland.Proxy.id device in
             let entry : Input_device.t =
               { device; name = !entry_name; role = Keyboard { xkb }; lifecycle = Active }
             in
             resolve_entry entry;
             Keyboard.set_device_repeat_info
               device
               ~rate:(Int32.of_int wm.config.repeat_rate)
               ~delay:(Int32.of_int wm.config.repeat_delay);
             Option.iter (Input_device.set_xkb wm entry) xkb
           | Some Pointer ->
             resolve_entry
               { device; name = !entry_name; role = Pointer; lifecycle = Active }
           | Some Touch ->
             resolve_entry
               { device; name = !entry_name; role = Touch; lifecycle = Active }
           | Some Tablet ->
             resolve_entry
               { device; name = !entry_name; role = Tablet; lifecycle = Active }
           | None -> Logs.err @@ fun m -> m "input device sent 'done' without a type")

       method on_removed _ =
         match entry_box.body with
         | Some entry -> Wm.remove_input_device wm entry
         | None -> Input_device.remove_device device
     end
;;

let on_xkb_keyboard xkb (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let device_ref : int32 option ref = ref None in
  Wayland.Proxy.Handler.attach xkb
  @@ object
       inherit [_] River.Xkb_config.River_xkb_keyboard_v1.v1

       method on_input_device _ ~device =
         let d = Wayland.Proxy.id device in
         device_ref := Some d;
         match Wm.find_input_device_opt wm d with
         | None ->
           Wm.add_xkb_stash wm d xkb;
           Logs.warn @@ fun m -> m "xkb keyboard for unknown device"
         | Some entry -> Input_device.set_xkb wm entry xkb

       method on_removed _ =
         Input_device.remove_xkb xkb;
         match !device_ref with
         | Some device ->
           (match Wm.find_input_device_opt wm device with
            | Some entry -> Input_device.clear_xkb entry xkb
            | None -> Wm.remove_xkb_stash wm device)
         | None -> ()

       method on_numlock_enabled _ = ()
       method on_numlock_disabled _ = ()
       method on_layout _ ~index ~name = ()
       method on_done _ = ()
       method on_capslock_enabled _ = ()
       method on_capslock_disabled _ = ()
     end
;;
