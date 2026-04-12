(* ocdwm window manager - state management *)
open Types
open Ocdwm_ipc.Types
open Ocdwm_config.Types

exception Unavailable
exception Finished

let handle_unavailable _proxy =
  Printf.eprintf
    "error: another window manager is already running\n";
  raise Unavailable

let handle_finished _ = raise Finished

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
      | Op_none, Some window ->
          Seat.pointer_move wm seat window
      | _, _ -> ()
      end
  | Resize_interactive ->
      begin match (seat.op, seat.hovered) with
      | Op_none, Some window ->
          Int32.logor Rwm.River_window_v1.Edges.right
            Rwm.River_window_v1.Edges.bottom
          |> Seat.pointer_resize wm seat window
      | _, _ -> ()
      end
  | Exit_wm ->
      Rwm.River_window_manager_v1.exit_session wm.wm_v1
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

let manage_window (wm : window_manager) (window : window) =
  begin match window.state with
  | W_new -> begin
      begin match window.output with
      | Some o -> begin
          o.windows <- window :: o.windows;
          o.focus_stack <- window :: o.focus_stack
        end
      | None -> ()
      end;
      Window.set_position window ~x:0l ~y:0l;
      Rwm.River_window_v1.propose_dimensions window.obj
        ~width:0l ~height:0l;
      window.state <- W_active
    end
  | _ -> ()
  end;
  match window.request with
  | Req_none -> ()
  | Req_move r -> begin
      Seat.pointer_move wm r.seat window;
      window.request <- Req_none
    end
  | Req_resize r -> begin
      Seat.pointer_resize wm r.seat window r.edges;
      window.request <- Req_none
    end

let remove_outputs (wm : window_manager) =
  wm.outputs <-
    List.filter
      (fun (o : output) ->
         match o.state with
         | O_active -> true
         | O_removed -> begin
             Output.destroy o.obj;
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
  | None -> wm.focused_output <- List.nth_opt wm.outputs 0
  | Some o ->
      begin match List.memq o wm.outputs with
      | false ->
          wm.focused_output <- List.nth_opt wm.outputs 0
      | true -> ()
      end

let handle_manage_start proxy (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  remove_outputs wm;
  close_windows wm;
  close_seats wm;
  maybe_focus_first_output wm;
  List.iter (manage_window wm) wm.windows;
  List.iter (manage_seat wm) wm.seats;
  Rwm.River_window_manager_v1.manage_finish proxy

let handle_render_start proxy (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  List.iter (render wm) wm.seats;
  Rwm.River_window_manager_v1.render_finish proxy

let handle_session_locked _proxy = ()
let handle_session_unlocked _proxy = ()

let handle_output _ river_output (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  let output : output =
    {
      obj = river_output;
      state = O_active;
      name = None;
      geom = { x = 0l; y = 0l; w = 0l; h = 0l };
      usable = { x = 0; y = 0; w = 0; h = 0 };
      selected_tags = 1l;
      previous_tags = 1l;
      tag_state =
        Array.init 32 (fun _ ->
          {
            layout_data = { name = "tile"; symbol = "[]=" };
            layout_params =
              {
                mfact = 0.55;
                nmaster = 1;
                gaps_inner = 0;
                gaps_outer = 0;
                stack = Stack_even;
              };
          });
      focus_stack = [];
      windows = [];
    }
  in
  Wayland.Proxy.Handler.attach river_output
    object
      inherit [_] Rwm.River_output_v1.v4
      method user_data = Output_data output
      method on_removed _ = output.state <- O_removed
      method on_wl_output _ ~name = ()
      method on_position _ ~x ~y = ()
      method on_dimensions _ ~width ~height = ()
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
      parent = None;
      geom = { x = 0l; y = 0l; w = 0l; h = 0l };
      old_geom = { x = 0l; y = 0l; w = 0l; h = 0l };
      size_hints =
        { min_w = 0l; max_w = 0l; min_h = 0l; max_h = 0l };
      tags = 1l;
      output = wm.focused_output;
      is_fixed = false;
      is_urgent = false;
      presentation = Tiled;
      request = Req_none;
    }
  in
  Wayland.Proxy.Handler.attach river_window
    object
      inherit [_] Rwm.River_window_v1.v4
      method user_data = Window_data window
      method on_closed _ = window.state <- W_closing

      method on_dimensions _ ~width ~height =
        window.geom <-
          {
            x = window.geom.x;
            y = window.geom.y;
            w = width;
            h = height;
          }

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

      method on_unreliable_pid _ ~unreliable_pid = ()
      method on_unmaximize_requested _ = ()
      method on_title _ ~title = ()
      method on_show_window_menu_requested _ ~x ~y = ()
      method on_presentation_hint _ ~hint = ()
      method on_parent _ ~parent = ()
      method on_minimize_requested _ = ()
      method on_maximize_requested _ = ()
      method on_identifier _ ~identifier = ()
      method on_fullscreen_requested _ ~output = ()
      method on_exit_fullscreen_requested _ = ()

      method on_dimensions_hint
        _
        ~min_width
        ~min_height
        ~max_width
        ~max_height =
        ()

      method on_decoration_hint _ ~hint = ()
      method on_app_id _ ~app_id = ()
    end;
  wm.windows <- window :: wm.windows

let handle_seat _ river_seat (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  let seat : seat =
    {
      obj = river_seat;
      state = S_new;
      output = wm.focused_output;
      xkb_bindings = [];
      pointer_bindings = [];
      pending_action = No_action;
      hovered = None;
      interacted = None;
      op = Op_none;
    }
  in
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

      method on_pointer_position _ ~x ~y = ()
    end;
  wm.seats <- seat :: wm.seats
