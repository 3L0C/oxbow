(* ocdwm handlers *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Config = Ocdwm_config.Config
module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_core.Types
open Types

let handle_output _ river_output (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  let output_box : output_box = { body = None } in
  let layer_shell =
    Rlsh.River_layer_shell_v1.get_output wm.river_lsh_v1
      ~output:river_output
    @@ object
         inherit [_] Rlsh.River_layer_shell_output_v1.v1

         method user_data =
           Boxed_data (Output_box output_box)

         method on_non_exclusive_area
           proxy
           ~x
           ~y
           ~width
           ~height =
           match Wayland.Proxy.user_data proxy with
           | Boxed_data (Output_box { body = Some o }) ->
           begin
               o.usable <-
                 Int32.
                   {
                     x = to_int x;
                     y = to_int y;
                     w = to_int width;
                     h = to_int height;
                   };
               Output.mark_dirty o
             end
           | _ -> assert false
       end
  in
  let output : output =
    {
      obj = river_output;
      layer_shell;
      state = O_active;
      name = None;
      geom = { x = 0l; y = 0l; w = 0l; h = 0l };
      usable = { x = 0; y = 0; w = 0; h = 0 };
      selected_tags = Tag_set.singleton 1;
      previous_tags = Tag_set.singleton 1;
      tag_state =
        Array.init 32 (fun _ ->
          Config.create_tag_data
            ~entry:wm.config.default_tag_config.layout_entry);
      focus_stack = [];
      windows = [];
    }
  in
  output_box.body <- Some output;
  Wayland.Proxy.Handler.attach river_output
    object
      inherit [_] Rwm.River_output_v1.v4
      method user_data = Output_data output
      method on_removed _ = output.state <- O_removed

      method on_wl_output _ ~name =
        begin
          let _ =
            Wayland.Wayland_client.Wl_registry.bind
              (Wayland.Registry.wl_registry wm.registry)
              ~name
            @@ ( object
                   inherit
                     [_] Wayland.Wayland_client.Wl_output.v4

                   method on_name _ ~name =
                     output.name <- Some name

                   method on_scale _ ~factor = ()

                   method on_mode
                     _
                     ~flags
                     ~width
                     ~height
                     ~refresh =
                     ()

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
                 end,
                 4l )
          in
          ()
        end

      method on_position _ ~x ~y =
        output.geom <-
          { x; y; w = output.geom.w; h = output.geom.h };
        if output.usable.w = 0 || output.usable.h = 0 then
          output.usable <-
            Int32.
              {
                x = to_int output.geom.x;
                y = to_int output.geom.y;
                w = to_int output.geom.w;
                h = to_int output.geom.h;
              }

      method on_dimensions _ ~width ~height =
        output.geom <-
          {
            x = output.geom.x;
            y = output.geom.y;
            w = width;
            h = height;
          };
        if output.usable.w = 0 || output.usable.h = 0 then
          output.usable <-
            Int32.
              {
                x = to_int output.geom.x;
                y = to_int output.geom.y;
                w = to_int output.geom.w;
                h = to_int output.geom.h;
              }
    end;
  wm.outputs <- output :: wm.outputs;
  match List.length wm.outputs with
  | 1 -> wm.focused_output <- Some output
  | _ -> ()

let handle_window _ river_window (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  let node =
    object
      inherit [_] Rwm.River_node_v1.v4
    end
  in
  let window : window =
    {
      obj = river_window;
      node = Rwm.River_window_v1.get_node river_window node;
      state = W_new;
      app_id = None;
      title = None;
      identifier = None;
      unreliable_pid = None;
      parent = None;
      decoration_hint = None;
      presentation_hint = None;
      geom = { x = 0l; y = 0l; w = 0l; h = 0l };
      float_geom = None;
      size_hints =
        { min_w = 0l; max_w = 0l; min_h = 0l; max_h = 0l };
      tags =
        begin match wm.focused_output with
        | None -> Tag_set.singleton 1
        | Some o -> o.selected_tags
        end;
      output = wm.focused_output;
      is_fixed = false;
      is_urgent = false;
      is_maximized = false;
      is_hidden = false;
      presentation = P_tiled;
      requests = [];
    }
  in
  Wayland.Proxy.Handler.attach river_window
    object
      inherit [_] Rwm.River_window_v1.v4
      method user_data = Window_data window
      method on_closed _ = window.state <- W_closing

      method on_dimensions _ ~width ~height =
        if window.geom.w <> width || window.geom.h <> height
        then begin
          Output.mark_dirty_opt window.output;
          Req_dimensions { width; height }
          |> Window.queue_request window
        end

      method on_unreliable_pid _ ~unreliable_pid =
        window.unreliable_pid <- Some unreliable_pid

      method on_parent _ ~parent = ()
      method on_title _ ~title = window.title <- title

      method on_identifier _ ~identifier =
        window.identifier <- Some identifier

      method on_dimensions_hint
        _
        ~min_width
        ~min_height
        ~max_width
        ~max_height =
        window.is_fixed <-
          Int32.(
            min_width > 0l
            && min_height > 0l
            && min_width = max_width
            && min_height = max_height);
        window.size_hints <-
          {
            min_w = min_width;
            max_w = max_width;
            min_h = min_height;
            max_h = max_height;
          }

      method on_decoration_hint _ ~hint =
        Rwm.River_window_v1.Decoration_hint.(
          window.decoration_hint <-
            Some
              (match hint with
              | Only_supports_csd -> W_only_csd
              | Prefers_csd -> W_prefer_csd
              | Prefers_ssd -> W_prefer_ssd
              | No_preference -> W_no_preference))

      method on_app_id _ ~app_id = window.app_id <- app_id

      method on_pointer_move_requested _ ~seat =
        match Wayland.Proxy.user_data seat with
        | Seat_data s ->
            Req_move { seat = s }
            |> Window.queue_request window
        | _ -> assert false

      method on_pointer_resize_requested _ ~seat ~edges =
        match Wayland.Proxy.user_data seat with
        | Seat_data s ->
            Req_resize { seat = s; edges }
            |> Window.queue_request window
        | _ -> assert false

      method on_maximize_requested _ =
        Window.queue_request window Req_maximize

      method on_unmaximize_requested _ =
        Window.queue_request window Req_unmaximize

      method on_fullscreen_requested _ ~output =
        match output with
        | Some o ->
            begin match Wayland.Proxy.user_data o with
            | Output_data o ->
                Req_fullscreen { output = Some o }
                |> Window.queue_request window
            | _ -> assert false
            end
        | None ->
            Req_fullscreen { output = None }
            |> Window.queue_request window

      method on_exit_fullscreen_requested _ =
        Window.queue_request window Req_exit_fullscreen

      method on_presentation_hint _ ~hint =
        window.presentation_hint <- Some hint

      method on_show_window_menu_requested _ ~x ~y = ()
      method on_minimize_requested _ = ()
    end;
  wm.windows <- window :: wm.windows

let handle_seat _ river_seat (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  let seat_box : seat_box = { body = None } in
  let layer_shell =
    Rlsh.River_layer_shell_v1.get_seat wm.river_lsh_v1
      ~seat:river_seat
    @@ object
         inherit [_] Rlsh.River_layer_shell_seat_v1.v1
         method user_data = Boxed_data (Seat_box seat_box)

         method on_focus_none proxy =
           let s =
             match Wayland.Proxy.user_data proxy with
             | Boxed_data (Seat_box { body = Some s }) -> s
             | _ -> assert false
           in
           s.layer_focus <- Lf_none;
           begin match Focus.focused_of s with
           | Some w -> Focus.focus_window ~force:true wm s w
           | None -> Focus.clear s
           end

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
  let seat : seat =
    {
      obj = river_seat;
      layer_shell;
      state = S_new;
      output = wm.focused_output;
      position = { x = 0l; y = 0l };
      layer_focus = Lf_none;
      xkb_bindings = [];
      pointer_bindings = [];
      pending_action = No_action;
      hovered = None;
      interacted = None;
      focus_request = Focus_none;
      cursor_target = None;
      op = Op_none;
    }
  in
  seat_box.body <- Some seat;
  Wayland.Proxy.Handler.attach river_seat
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
        | Op_move d -> begin
            d.dx <- dx;
            d.dy <- dy
          end
        | Op_resize d -> begin
            d.dx <- dx;
            d.dy <- dy
          end
        | Op_none -> ()

      method on_op_release _ =
        match seat.op with
        | Op_move d -> d.release <- true
        | Op_resize d -> d.release <- true
        | Op_none -> ()

      method on_wl_seat _ ~name = ()

      method on_shell_surface_interaction _ ~shell_surface =
        ()

      method on_pointer_position _ ~x ~y =
        Seat.handle_pointer_position wm seat ~x ~y
    end;
  wm.seats <- seat :: wm.seats
