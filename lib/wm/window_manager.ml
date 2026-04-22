(* ocdwm window manager - state management *)

module Layout = Ocdwm_layout.Layout
module Config = Ocdwm_config.Config
open Types
open Ocdwm_core.Types
open Ocdwm_ipc.Types
open Ocdwm_config.Types

exception Unavailable
exception Finished

let handle_unavailable _proxy =
  Printf.eprintf
    "error: another window manager is already running\n";
  raise Unavailable

let handle_finished _ = raise Finished

let set_presentation_mode (output : output) =
  match Output.focused_window output with
  | Some w when w.output <> None -> begin
      let mode =
        match w.presentation_hint with
        | Some p -> p
        | None ->
            Rwm.River_output_v1.Presentation_mode.Vsync
      in
      Rwm.River_output_v1.set_presentation_mode output.obj
        ~mode
    end
  | _ ->
      Rwm.River_output_v1.set_presentation_mode output.obj
        ~mode:Rwm.River_output_v1.Presentation_mode.Vsync

let render (wm : window_manager) (seat : seat) =
  begin match seat.op with
  | Op_none -> ()
  | Op_move op_m ->
      Window.set_position op_m.window
        ~x:(Int32.add op_m.start_x op_m.dx)
        ~y:(Int32.add op_m.start_y op_m.dy)
  | Op_resize op_r ->
      let x =
        if
          Int32.logand op_r.edges
            Rwm.River_window_v1.Edges.left
          <> 0l
        then
          Int32.sub op_r.start_w op_r.window.geom.w
          |> Int32.add op_r.start_x
        else op_r.start_x
      in
      let y =
        if
          Int32.logand op_r.edges
            Rwm.River_window_v1.Edges.top
          <> 0l
        then
          Int32.sub op_r.start_h op_r.window.geom.h
          |> Int32.add op_r.start_y
        else op_r.start_y
      in
      Window.set_position op_r.window ~x ~y
  end;
  List.iter set_presentation_mode wm.outputs

let rec handle_window_request
          (wm : window_manager)
          (window : window)
  = function
  | Req_none -> ()
  | Req_move r ->
      begin match window.presentation with
      | P_fullscreen _ -> ()
      | _ -> begin
          if window.presentation = P_tiled then begin
            window.presentation <- P_floating;
            Output.mark_dirty window.output
          end;
          Seat.pointer_move wm r.seat window
        end
      end
  | Req_resize r ->
      begin match window.presentation with
      | P_fullscreen _ -> ()
      | _ -> begin
          if window.presentation = P_tiled then begin
            window.presentation <- P_floating;
            Output.mark_dirty window.output
          end;
          Seat.pointer_resize wm r.seat window r.edges
        end
      end
  | Req_maximize -> begin
      window.is_maximized <- true;
      Rwm.River_window_v1.inform_maximized window.obj
    end
  | Req_unmaximize -> begin
      window.is_maximized <- false;
      Rwm.River_window_v1.inform_unmaximized window.obj
    end
  | Req_fullscreen r -> begin
      let enter (restore : [ `Tiled | `Floating ]) =
        match (r.output, window.output) with
        | None, None -> ()
        | Some o, _
        | None, Some o -> begin
            List.iter
              (fun w ->
                 if Window.is_fullscreen w then
                   handle_window_request wm w
                     Req_exit_fullscreen)
              o.focus_stack;
            List.iter
              (fun (s : seat) ->
                 match s.op with
                 | Op_move op when op.window == window ->
                     s.op <- Op_none
                 | Op_resize op when op.window == window ->
                     s.op <- Op_none
                 | _ -> ())
              wm.seats;
            window.presentation <- P_fullscreen { restore };
            Output.mark_dirty window.output;
            Output.move_window window o;
            Output.mark_dirty (Some o);
            Window.fullscreen window
          end
      in
      match window.presentation with
      | P_tiled -> enter `Tiled
      | P_floating -> enter `Floating
      | P_fullscreen _ ->
          begin match (r.output, window.output) with
          | Some o1, Some o2 when o1 != o2 ->
              Output.mark_dirty (Some o2);
              Output.move_window window o1;
              Output.mark_dirty (Some o1);
              Window.fullscreen window
          | _, _ -> ()
          end
    end
  | Req_exit_fullscreen ->
      begin match window.presentation with
      | P_tiled
      | P_floating ->
          ()
      | P_fullscreen { restore } -> begin
          Window.exit_fullscreen window restore;
          Output.mark_dirty window.output
        end
      end

let action (wm : window_manager) (seat : seat) = function
  | No_action -> ()
  | Spawn cmd -> Ocdwm_core.Utils.spawn cmd
  | Close_focused ->
      begin match Focus.focused_of seat with
      | Some window -> Rwm.River_window_v1.close window.obj
      | None -> ()
      end
  | Focus_window dir -> Focus.focus_dir wm seat dir
  | Move_interactive ->
      begin match (seat.op, seat.hovered) with
      | Op_none, Some window -> begin
          handle_window_request wm window
            (Req_move { seat })
        end
      | _, _ -> ()
      end
  | Resize_interactive ->
      begin match (seat.op, seat.hovered) with
      | Op_none, Some window -> begin
          handle_window_request wm window
            (Req_resize
               {
                 seat;
                 edges =
                   Int32.logor
                     Rwm.River_window_v1.Edges.right
                     Rwm.River_window_v1.Edges.bottom;
               })
        end
      | _, _ -> ()
      end
  | Exit_wm ->
      Rwm.River_window_manager_v1.exit_session
        wm.river_wm_v1
  | Toggle_floating ->
      begin match Focus.focused_of seat with
      | None -> ()
      | Some w ->
          begin match w.presentation with
          | P_fullscreen _ -> ()
          | _ -> begin
              Window.toggle_floating (Some w);
              Output.mark_dirty seat.output
            end
          end
      end
  | Toggle_fullscreen ->
      begin match Focus.focused_of seat with
      | None -> ()
      | Some w ->
          begin match w.presentation with
          | P_fullscreen _ ->
              handle_window_request wm w Req_exit_fullscreen
          | _ ->
              handle_window_request wm w
                (Req_fullscreen { output = w.output })
          end
      end
  | Toggle_maximize ->
      begin match Focus.focused_of seat with
      | None -> ()
      | Some w ->
          begin match w.presentation with
          | P_fullscreen _ -> ()
          | _ ->
              (if w.is_maximized then Req_unmaximize
               else Req_maximize)
              |> handle_window_request wm w
          end
      end
  | Layout_set name ->
      begin match
        Layout.find ~registry:wm.layout_registry ~name
      with
      | None -> ()
      | Some entry ->
          begin match wm.focused_output with
          | None -> ()
          | Some o -> begin
              let old_name =
                Output.current_layout_entry o
                |> Layout.entry_name
              in
              if old_name = "floating" then
                Output.tiled_windows o
                |> List.iter Window.remember_float;
              Output.set_layout_entry o ~entry;
              Output.mark_dirty (Some o)
            end
          end
      end
  | Layout_cycle dir ->
      begin match wm.focused_output with
      | None -> ()
      | Some o -> begin
          let name =
            Output.current_layout_entry o
            |> Layout.entry_name
          in
          match
            Layout.cycle ~registry:wm.layout_registry ~name
              ~dir
          with
          | None -> ()
          | Some (_, entry) -> begin
              if name = "floating" then
                Output.tiled_windows o
                |> List.iter Window.remember_float;
              Output.set_layout_entry o ~entry;
              Output.mark_dirty (Some o)
            end
        end
      end
  | _ -> ()

let manage_seat (wm : window_manager) (seat : seat) =
  begin match seat.state with
  | S_new -> begin
      Seat.init wm seat;
      seat.state <- S_active
    end
  | _ -> ()
  end;
  begin match seat.interacted with
  | Some w -> Focus.focus_window wm seat w
  | None -> ()
  end;
  seat.interacted <- None;
  action wm seat seat.pending_action;
  seat.pending_action <- No_action;
  Seat.op wm seat

let retile (wm : window_manager) = function
  | None -> ()
  | Some (o : output) ->
      if not @@ Output.fullscreen_is_visible o then begin
        let windows = Output.tiled_windows o in
        let count = List.length windows in
        let tag_data = Output.tag_data o in
        let compute =
          Layout.compute ~entry:tag_data.layout_entry
        in
        let dimensions =
          compute ~data:tag_data.layout_params
            ~area:o.usable ~count
        in
        match (windows, dimensions) with
        | _, [] when count <> 0 ->
            List.iter
              (fun w -> Window.restore_or_seed_float w)
              windows
        | _, d_xs when List.length d_xs <> count ->
            let layout_name =
              Layout.entry_name tag_data.layout_entry
            in
            Logs.warn (fun m ->
              m
                "Layout %S returned unexpected geometry \
                 count"
                 layout_name)
        | w_xs, d_xs ->
            List.iter2
              (fun w g ->
                 Window.clamp w g |> Window.set_geom w)
              w_xs d_xs
      end

let manage_window (wm : window_manager) (window : window) =
  begin match window.state with
  | W_new -> begin
      Rwm.River_window_v1.set_capabilities window.obj
        ~caps:
          Rwm.River_window_v1.Capabilities.(
            Int32.logor maximize fullscreen);
      Output.add_window window;
      Output.mark_dirty window.output;
      if window.is_fixed then
        window.presentation <- P_floating;
      window.state <- W_active
    end
  | _ -> ()
  end;
  handle_window_request wm window window.request;
  window.request <- Req_none

let remove_outputs (wm : window_manager) =
  wm.outputs <-
    List.filter
      (fun (o : output) ->
         match o.state with
         | O_dirty
         | O_active ->
             true
         | O_removed -> begin
             Output.destroy o;
             false
           end)
      wm.outputs

let close_windows (wm : window_manager) =
  wm.windows <-
    List.filter
      (fun (w : window) ->
         match w.state with
         | W_closing -> begin
             Seat.disconnect_seats wm.seats w;
             Focus.remove_window wm w;
             Window.destroy w;
             Output.mark_dirty w.output;
             false
           end
         | _ -> true)
      wm.windows

let close_seats (wm : window_manager) =
  wm.seats <-
    List.filter
      (fun (s : seat) ->
         match s.state with
         | S_closing -> begin
             Seat.destroy s;
             false
           end
         | _ -> true)
      wm.seats

let maybe_focus_first_output (wm : window_manager) =
  match wm.focused_output with
  | None ->
      begin match wm.outputs with
      | o :: _ -> begin
          wm.focused_output <- Some o;
          Rlsh.River_layer_shell_output_v1.set_default
            o.layer_shell
        end
      | [] -> ()
      end
  | Some o ->
      begin match List.memq o wm.outputs with
      | false ->
          begin match wm.outputs with
          | o :: _ -> begin
              wm.focused_output <- Some o;
              Rlsh.River_layer_shell_output_v1.set_default
                o.layer_shell
            end
          | [] -> ()
          end
      | true -> ()
      end

let manage_output (wm : window_manager) (output : output) =
  begin match output.state with
  | O_dirty ->
      Some output |> retile wm;
      Some output |> Focus.refresh_focus wm;
      output.state <- O_active
  | _ -> ()
  end

let handle_manage_start proxy (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  remove_outputs wm;
  close_windows wm;
  close_seats wm;
  maybe_focus_first_output wm;
  List.iter (manage_window wm) wm.windows;
  List.iter (manage_seat wm) wm.seats;
  List.iter (manage_output wm) wm.outputs;
  Rwm.River_window_manager_v1.manage_finish proxy

let handle_render_start proxy (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  List.iter (render wm) wm.seats;
  Rwm.River_window_manager_v1.render_finish proxy

let handle_session_locked _proxy = ()
let handle_session_unlocked _proxy = ()

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
               Output.mark_dirty (Some o)
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
      selected_tags = 1l;
      previous_tags = 1l;
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
      tags = 1l;
      output = wm.focused_output;
      is_fixed = false;
      is_urgent = false;
      is_maximized = false;
      presentation = P_tiled;
      request = Req_none;
    }
  in
  Wayland.Proxy.Handler.attach river_window
    object
      inherit [_] Rwm.River_window_v1.v4
      method user_data = Window_data window
      method on_closed _ = window.state <- W_closing

      method on_dimensions _ ~width ~height =
        match
          window.geom.w <> width || window.geom.h <> height
        with
        | false -> ()
        | true -> Output.mark_dirty window.output

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
            window.request <- Req_move { seat = s }
        | _ -> assert false

      method on_pointer_resize_requested _ ~seat ~edges =
        match Wayland.Proxy.user_data seat with
        | Seat_data s ->
            window.request <- Req_resize { seat = s; edges }
        | _ -> assert false

      method on_maximize_requested _ =
        window.request <- Req_maximize

      method on_unmaximize_requested _ =
        window.request <- Req_unmaximize

      method on_fullscreen_requested _ ~output =
        match output with
        | Some o ->
            begin match Wayland.Proxy.user_data o with
            | Output_data o ->
                window.request <-
                  Req_fullscreen { output = Some o }
            | _ -> assert false
            end
        | None ->
            window.request <-
              Req_fullscreen { output = None }

      method on_exit_fullscreen_requested _ =
        window.request <- Req_exit_fullscreen

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
           s.layer_focus <- Lf_non_exclusive;
           begin match Focus.focused_of s with
           | Some w -> Focus.focus_window ~force:true wm s w
           | None -> Focus.clear s
           end

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
        seat.position <- { x; y }
    end;
  wm.seats <- seat :: wm.seats
