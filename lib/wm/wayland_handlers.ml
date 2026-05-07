module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
open! Ocdwm_core

type (_, _) Wayland.S.user_data +=
  | Boxed_data of Any_box.t
  | Output_data of Types.Output.t
  | Window_data of Types.Window.t
  | Seat_data of Types.Seat.t

let on_finished (wm_box : Types.Window_manager.t Box.t) =
  match wm_box.body with
  | None -> ()
  | Some wm ->
    wm.finish_received <- true;
    Window_manager.request_shutdown ~origin:`Compositor wm
;;

let remove_outputs (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  wm.outputs
  <- List.filter
       (fun (o : Types.Output.t) ->
          match o.state with
          | O_dirty _ | O_active -> true
          | O_removed ->
            Output.destroy o;
            false)
       wm.outputs;
  match wm.outputs with
  | [] -> Window_manager.focus_output ctx None
  | _ -> ()
;;

let disconnect_seat (window : Types.Window.t) (seat : Types.Seat.t) =
  (match seat.hovered with
   | Some w when w == window -> seat.hovered <- None
   | _ -> ());
  (match seat.interacted with
   | Some w when w == window -> seat.interacted <- None
   | _ -> ());
  (match seat.focus_request with
   | Focus_window w when w == window -> seat.focus_request <- Focus_none
   | _ -> ());
  (match seat.cursor_target with
   | Some w when w == window -> seat.cursor_target <- None
   | _ -> ());
  match seat.op with
  | (Op_move { window = w; _ } | Op_resize { window = w; _ }) when w == window ->
    Rwm.River_seat_v1.op_end seat.obj;
    seat.op <- Op_none
  | _ -> ()
;;

let disconnect_seats (window : Types.Window.t) = List.iter (disconnect_seat window)

let close_windows (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  wm.windows
  <- List.filter
       (fun (w : Types.Window.t) ->
          match w.state with
          | W_closing ->
            disconnect_seats w wm.seats;
            Focus.remove_window ctx w;
            Window.destroy w;
            Option.iter (Output.mark_dirty wm) w.output;
            false
          | _ -> true)
       wm.windows
;;

let close_seats (wm : Types.Window_manager.t) =
  wm.seats
  <- List.filter
       (fun (s : Types.Seat.t) ->
          match s.state with
          | S_closing ->
            Seat.destroy s;
            false
          | _ -> true)
       wm.seats
;;

let manage_window (ctx : Ctx.manage Ctx.t) (window : Types.Window.t) =
  let wm = Ctx.wm ctx in
  (match window.state with
   | W_new ->
     Rwm.River_window_v1.set_capabilities
       window.obj
       ~caps:Rwm.River_window_v1.Capabilities.(Int32.logor maximize fullscreen);
     Option.iter (Output.add_window ~window) window.output;
     Option.iter (Output.mark_dirty wm) window.output;
     if window.is_fixed then window.presentation <- P_floating;
     window.state <- W_active
   | _ -> ());
  List.rev window.requests |> List.iter (Requests.window_request ctx window);
  Window.clear_requests window
;;

let on_new_seat (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  match seat.state with
  | S_new ->
    Seat.init ctx seat;
    seat.state <- S_active
  | _ -> ()
;;

let manage_seat (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  on_new_seat ctx seat;
  Seat.sync ctx seat;
  Requests.focus_request ctx seat;
  Requests.interaction ctx seat;
  Queue.iter (Requests.action ctx seat) seat.pending_actions;
  Queue.clear seat.pending_actions;
  Operations.seat_op ctx seat
;;

let manage_output (ctx : Ctx.manage Ctx.t) (output : Types.Output.t) =
  match output.state with
  | O_dirty { prev } ->
    Output.retile ctx output;
    Focus.refresh_focus ctx output;
    output.state <- prev
  | _ -> ()
;;

let on_manage_start proxy (wm_box : Types.Window_manager.t Box.t) =
  let wm = Option.get wm_box.body in
  Ctx.with_manage wm (fun ctx ->
    Window_manager.sync ctx;
    remove_outputs ctx;
    close_windows ctx;
    close_seats wm;
    Focus.sync ctx;
    List.iter (manage_window ctx) wm.windows;
    List.iter (manage_seat ctx) wm.seats;
    List.iter (manage_output ctx) wm.outputs;
    List.iter (Window.sync ctx) wm.windows;
    Rwm.River_window_manager_v1.manage_finish proxy)
;;

let on_output _ river_output (wm_box : Types.Window_manager.t Box.t) =
  let wm = Option.get wm_box.body in
  let output_box : Types.Output.t Box.t = { body = None } in
  let layer_shell =
    Rlsh.River_layer_shell_v1.get_output wm.river_lsh_v1 ~output:river_output
    @@ object
         inherit [_] Rlsh.River_layer_shell_output_v1.v1
         method user_data = Boxed_data (Output_box output_box)

         method on_non_exclusive_area proxy ~x ~y ~width ~height =
           match Wayland.Proxy.user_data proxy with
           | Boxed_data (Output_box { body = Some o }) ->
             o.usable
             <- Int32.{ x = to_int x; y = to_int y; w = to_int width; h = to_int height };
             Output.mark_dirty wm o
           | _ -> assert false
       end
  in
  let output : Types.Output.t =
    { obj = river_output
    ; layer_shell
    ; state = O_active
    ; name = None
    ; geom = { x = 0l; y = 0l; w = 0l; h = 0l }
    ; usable = { x = 0; y = 0; w = 0; h = 0 }
    ; selected_tags = Tag_set.singleton 1
    ; previous_tags = Tag_set.singleton 1
    ; tag_state =
        Array.init 32 (fun _ ->
          Config.create_tag_data ~entry:wm.config.default_tag_config.layout_entry)
    ; focus_stack = []
    ; windows = []
    }
  in
  output_box.body <- Some output;
  Wayland.Proxy.Handler.attach
    river_output
    object
      inherit [_] Rwm.River_output_v1.v4
      method user_data = Output_data output
      method on_removed _ = output.state <- O_removed

      method on_wl_output _ ~name =
        let _ =
          Wayland.Wayland_client.Wl_registry.bind
            (Wayland.Registry.wl_registry wm.registry)
            ~name
          @@ ( object
                 inherit [_] Wayland.Wayland_client.Wl_output.v4
                 method on_name _ ~name = output.name <- Some name
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
        output.geom <- { x; y; w = output.geom.w; h = output.geom.h };
        if output.usable.w = 0 || output.usable.h = 0
        then
          output.usable
          <- Int32.
               { x = to_int output.geom.x
               ; y = to_int output.geom.y
               ; w = to_int output.geom.w
               ; h = to_int output.geom.h
               }

      method on_dimensions _ ~width ~height =
        output.geom <- { x = output.geom.x; y = output.geom.y; w = width; h = height };
        if output.usable.w = 0 || output.usable.h = 0
        then
          output.usable
          <- Int32.
               { x = to_int output.geom.x
               ; y = to_int output.geom.y
               ; w = to_int output.geom.w
               ; h = to_int output.geom.h
               }
    end;
  wm.outputs <- output :: wm.outputs;
  match List.length wm.outputs with
  | 1 -> Window_manager.set_focused_output wm @@ Some output
  | _ -> ()
;;

let set_presentation_mode (output : Types.Output.t) =
  match Output.focused_window output with
  | Some w when Option.is_some w.output ->
    let mode =
      match w.presentation_hint with
      | Some p -> p
      | None -> Rwm.River_output_v1.Presentation_mode.Vsync
    in
    Rwm.River_output_v1.set_presentation_mode output.obj ~mode
  | _ ->
    Rwm.River_output_v1.set_presentation_mode
      output.obj
      ~mode:Rwm.River_output_v1.Presentation_mode.Vsync
;;

let render (ctx : Ctx.render Ctx.t) (seat : Types.Seat.t) =
  let wm = Ctx.wm ctx in
  (match seat.op with
   | Op_none -> ()
   | Op_move op_m ->
     Window.set_position
       ctx
       op_m.window
       ~x:(Int32.add op_m.start_x op_m.dx)
       ~y:(Int32.add op_m.start_y op_m.dy)
   | Op_resize op_r ->
     let x =
       if Int32.logand op_r.edges Rwm.River_window_v1.Edges.left <> 0l
       then Int32.sub op_r.start_w op_r.window.geom.w |> Int32.add op_r.start_x
       else op_r.start_x
     in
     let y =
       if Int32.logand op_r.edges Rwm.River_window_v1.Edges.top <> 0l
       then Int32.sub op_r.start_h op_r.window.geom.h |> Int32.add op_r.start_y
       else op_r.start_y
     in
     Window.set_position ctx op_r.window ~x ~y);
  List.iter set_presentation_mode wm.outputs
;;

let on_render_start proxy (wm_box : Types.Window_manager.t Box.t) =
  let wm = Option.get wm_box.body in
  Ctx.with_render wm (fun ctx ->
    List.iter (render ctx) wm.seats;
    Rwm.River_window_manager_v1.render_finish proxy)
;;

let on_seat _ river_seat (wm_box : Types.Window_manager.t Box.t) =
  let wm = Option.get wm_box.body in
  let seat_box : Types.Seat.t Box.t = { body = None } in
  let layer_shell =
    Rlsh.River_layer_shell_v1.get_seat wm.river_lsh_v1 ~seat:river_seat
    @@ object
         inherit [_] Rlsh.River_layer_shell_seat_v1.v1
         method user_data = Boxed_data (Seat_box seat_box)

         method on_focus_none proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Boxed_data (Seat_box { body = Some s }) -> s
             | _ -> assert false
           in
           s.layer_focus <- Layer_focus.Lf_none;
           Seat.mark_dirty wm s

         method on_focus_non_exclusive proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Boxed_data (Seat_box { body = Some s }) -> s
             | _ -> assert false
           in
           s.layer_focus <- Lf_non_exclusive

         method on_focus_exclusive proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Boxed_data (Seat_box { body = Some s }) -> s
             | _ -> assert false
           in
           s.layer_focus <- Lf_exclusive
       end
  in
  let seat : Seat.t =
    { obj = river_seat
    ; layer_shell
    ; state = S_new
    ; name = None
    ; output = wm.focused_output
    ; position = { x = 0l; y = 0l }
    ; layer_focus = Lf_none
    ; xkb_bindings = []
    ; pointer_bindings = []
    ; pending_actions = Queue.create ()
    ; hovered = None
    ; interacted = None
    ; focus_request = Focus_none
    ; cursor_target = None
    ; op = Op_none
    }
  in
  seat_box.body <- Some seat;
  Wayland.Proxy.Handler.attach
    river_seat
    object
      inherit [_] Rwm.River_seat_v1.v4
      method user_data = Seat_data seat
      method on_removed _ = seat.state <- S_closing

      method on_pointer_enter _ ~window =
        match Wayland.Proxy.user_data window with
        | Window_data w -> seat.hovered <- Some w
        | _ -> assert false

      method on_pointer_leave _ = seat.hovered <- None

      method on_window_interaction _ ~window =
        match Wayland.Proxy.user_data window with
        | Window_data w -> seat.interacted <- Some w
        | _ -> assert false

      method on_op_delta _ ~dx ~dy =
        match seat.op with
        | Op_move d ->
          d.dx <- dx;
          d.dy <- dy
        | Op_resize d ->
          d.dx <- dx;
          d.dy <- dy
        | Op_none -> ()

      method on_op_release _ =
        match seat.op with
        | Op_move d -> d.release <- true
        | Op_resize d -> d.release <- true
        | Op_none -> ()

      method on_wl_seat _ ~name =
        let _ =
          Wayland.Wayland_client.Wl_registry.bind
            (Wayland.Registry.wl_registry wm.registry)
            ~name
          @@ ( object
                 inherit [_] Wayland.Wayland_client.Wl_seat.v9

                 method on_name _ ~name =
                   Logs.info (fun m -> m "Seat: Name: %S" name);
                   seat.name <- Some name

                 method on_capabilities _ ~capabilities = ()
               end
             , 9l )
        in
        ()

      method on_shell_surface_interaction _ ~shell_surface = ()
      method on_pointer_position _ ~x ~y = Seat.handle_pointer_position wm seat ~x ~y
    end;
  wm.seats <- seat :: wm.seats
;;

let on_session_locked _proxy = ()
let on_session_unlocked _proxy = ()

let on_unavailable _proxy =
  Printf.eprintf "error: another window manager is already running\n";
  raise Exceptions.Unavailable
;;

let on_window _ river_window (wm_box : Window_manager.t Box.t) =
  let wm = Option.get wm_box.body in
  let window = Window.create wm river_window in
  Wayland.Proxy.Handler.attach
    river_window
    object
      inherit [_] Rwm.River_window_v1.v4
      method user_data = Window_data window
      method on_closed _ = window.state <- W_closing

      method on_dimensions _ ~width ~height =
        if window.geom.w <> width || window.geom.h <> height
        then (
          Option.iter (Output.mark_dirty wm) window.output;
          Req_dimensions { width; height } |> Window.queue_request window)

      method on_unreliable_pid _ ~unreliable_pid =
        window.unreliable_pid <- Some unreliable_pid

      method on_parent _ ~parent = ()
      method on_title _ ~title = window.title <- title
      method on_identifier _ ~identifier = window.identifier <- Some identifier

      method on_dimensions_hint _ ~min_width ~min_height ~max_width ~max_height =
        window.is_fixed
        <- Int32.(
             min_width > 0l
             && min_height > 0l
             && min_width = max_width
             && min_height = max_height);
        window.size_hints
        <- { min_w = min_width
           ; max_w = max_width
           ; min_h = min_height
           ; max_h = max_height
           }

      method on_decoration_hint _ ~hint =
        Rwm.River_window_v1.Decoration_hint.(
          window.decoration_hint
          <- Some
               (match hint with
                | Only_supports_csd -> W_only_csd
                | Prefers_csd -> W_prefer_csd
                | Prefers_ssd -> W_prefer_ssd
                | No_preference -> W_no_preference))

      method on_app_id _ ~app_id = window.app_id <- app_id

      method on_pointer_move_requested _ ~seat =
        match Wayland.Proxy.user_data seat with
        | Seat_data s -> Req_move { seat = s } |> Window.queue_request window
        | _ -> assert false

      method on_pointer_resize_requested _ ~seat ~edges =
        match Wayland.Proxy.user_data seat with
        | Seat_data s -> Req_resize { seat = s; edges } |> Window.queue_request window
        | _ -> assert false

      method on_maximize_requested _ = Window.queue_request window Req_maximize
      method on_unmaximize_requested _ = Window.queue_request window Req_unmaximize

      method on_fullscreen_requested _ ~output =
        match output with
        | Some o ->
          (match Wayland.Proxy.user_data o with
           | Output_data o ->
             Req_fullscreen { output = Some o } |> Window.queue_request window
           | _ -> assert false)
        | None -> Req_fullscreen { output = None } |> Window.queue_request window

      method on_exit_fullscreen_requested _ =
        Window.queue_request window Req_exit_fullscreen

      method on_presentation_hint _ ~hint = window.presentation_hint <- Some hint
      method on_show_window_menu_requested _ ~x ~y = ()
      method on_minimize_requested _ = ()
    end;
  wm.windows <- window :: wm.windows
;;
