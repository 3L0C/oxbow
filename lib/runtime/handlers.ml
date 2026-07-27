open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ops

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
    ; selected_tags = Tag.Set.singleton 1
    ; previous_tags = Tag.Set.singleton 1
    ; overview = false
    ; scroll_offset = 0
    ; tag_data = Array.init 32 (fun _ -> Config.create_tag_data ())
    ; focus_stack = []
    ; wm_stack = []
    }
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
            (Wayland.Registry.wl_registry wm.registry)
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
            (Wayland.Registry.wl_registry wm.registry)
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
      method on_pointer_position _ ~x ~y = Pointer.handle_position wm seat ~x ~y
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
        then (
          Schedule.manage ();
          Window.queue_request window @@ Dimensions { width; height })

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

      method on_maximize_requested _ = Window.queue_request window Maximize
      method on_unmaximize_requested _ = Window.queue_request window Unmaximize

      method on_fullscreen_requested _ ~output =
        let queue_request o = Window.queue_request window @@ Fullscreen { output = o } in
        Option.bind output (fun o -> Wm.find_output_opt wm @@ Wayland.Proxy.id o)
        |> queue_request

      method on_exit_fullscreen_requested _ = Window.queue_request window Exit_fullscreen

      method on_presentation_hint _ ~hint =
        Window.set_presentation_mode window @@ Some hint

      method on_show_window_menu_requested _ ~x:_ ~y:_ = ()
      method on_minimize_requested _ = ()
    end;
  Wm.set_windows wm (window :: wm.windows)
;;

let on_input_device device (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let entry_kind : River.Proto.Input.Management.River_input_device_v1.Type.t option ref =
    ref None
  in
  let entry_name = ref "" in
  let entry_box : Input_device.t Box.t = { body = None } in
  let resolve_entry entry =
    Box.fill entry_box entry;
    Wm.add_input_device wm entry
  in
  Wayland.Proxy.Handler.attach device
  @@ object
       inherit [_] River.Input.Management.River_input_device_v1.v1
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
         | None -> Emit.destroy_input_device device
     end
;;

let on_xkb_keyboard xkb (wm_box : Wm.t Box.t) =
  let wm = Option.get wm_box.body in
  let device_ref : int32 option ref = ref None in
  Wayland.Proxy.Handler.attach xkb
  @@ object
       inherit [_] River.Xkb.Config.River_xkb_keyboard_v1.v1

       method on_input_device _ ~device =
         let d = Wayland.Proxy.id device in
         device_ref := Some d;
         match Wm.find_input_device_opt wm d with
         | None ->
           Wm.add_xkb_stash wm d xkb;
           Logs.warn @@ fun m -> m "xkb keyboard for unknown device"
         | Some entry -> Input_device.set_xkb wm entry xkb

       method on_removed _ =
         Emit.destroy_xkb_keyboard xkb;
         match !device_ref with
         | Some device ->
           (match Wm.find_input_device_opt wm device with
            | Some entry -> Input_device.clear_xkb entry xkb
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
