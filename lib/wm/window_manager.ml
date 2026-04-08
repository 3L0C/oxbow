(* ocdwm window manager - state management *)
open Types

exception Unavailable
exception Finished

let create () =
  {
    wm_v1 = None;
    xkb_v1 = None;
    windows = [];
    outputs = [];
    seats = [];
    seat_handler =
      {
        pointer_move = Seat.pointer_move;
        pointer_resize = Seat.pointer_resize;
      };
    window_handler = { set_position = Window.set_position };
  }

let handle_unavailable _proxy =
  Printf.eprintf
    "error: another window manager is already running\n";
  raise Unavailable

let handle_finished _ = raise Finished

let handle_manage_start proxy (wm : window_manager) =
  wm.outputs <-
    List.filter
      (fun (output : output) ->
         match output.removed with
         | false -> true
         | true ->
             Output.destroy output.obj;
             false)
      wm.outputs;
  wm.windows <-
    List.filter
      (fun window ->
         match window.closed with
         | false -> true
         | true ->
             Seat.disconnect_seats wm.seats window;
             Window.destroy window;
             false)
      wm.windows;
  wm.seats <-
    List.filter
      (fun (seat : seat) ->
         match seat.removed with
         | false -> true
         | true ->
             Seat.destroy seat;
             false)
      wm.seats;
  List.iter (Window.manage wm) wm.windows;
  List.iter (Seat.manage wm) wm.seats;
  Rwm.River_window_manager_v1.manage_finish proxy

let handle_render_start proxy (wm : window_manager) =
  List.iter (Seat.render wm) wm.seats;
  Rwm.River_window_manager_v1.render_finish proxy

let handle_session_locked _proxy = ()
let handle_session_unlocked _proxy = ()

let handle_output _ river_output (wm : window_manager) =
  let output : output =
    { obj = river_output; removed = false }
  in
  Wayland.Proxy.Handler.attach river_output
    object
      inherit [_] Rwm.River_output_v1.v4
      method user_data = Output_data output
      method on_removed _ = output.removed <- true
      method on_wl_output _ ~name = ()
      method on_position _ ~x ~y = ()
      method on_dimensions _ ~width ~height = ()
    end;
  wm.outputs <- output :: wm.outputs

let handle_window _ river_window (wm : window_manager) =
  let node =
    object
      inherit [_] Rwm.River_node_v1.v4
    end
  in
  let window : window =
    {
      obj = river_window;
      node = Rwm.River_window_v1.get_node river_window node;
      is_new = true;
      closed = false;
      x = 0l;
      y = 0l;
      width = 0l;
      height = 0l;
      pointer_move_requested = None;
      pointer_resize_requested = None;
      pointer_resize_requested_edges =
        Rwm.River_window_v1.Edges.none;
    }
  in
  Wayland.Proxy.Handler.attach river_window
    object
      inherit [_] Rwm.River_window_v1.v4
      method user_data = Window_data window
      method on_closed _ = window.closed <- true

      method on_dimensions _ ~width ~height =
        window.width <- width;
        window.height <- height

      method on_pointer_move_requested _ ~seat =
        match Wayland.Proxy.user_data seat with
        | Seat_data s ->
            window.pointer_move_requested <- Some s
        | _ -> ()

      method on_pointer_resize_requested _ ~seat ~edges =
        match Wayland.Proxy.user_data seat with
        | Seat_data s -> begin
            window.pointer_resize_requested <- Some s;
            window.pointer_resize_requested_edges <- edges
          end
        | _ -> ()

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

let handle_seat _ river_seat (wm : window_manager) =
  let seat : seat =
    {
      obj = river_seat;
      is_new = true;
      removed = false;
      focused = None;
      hovered = None;
      interacted = None;
      xkb_bindings = [];
      pointer_bindings = [];
      pending_action = No_action;
      op = Op_none;
      op_window = None;
      op_start_x = 0l;
      op_start_y = 0l;
      op_dx = 0l;
      op_dy = 0l;
      op_release = false;
      op_start_width = 0l;
      op_start_height = 0l;
      op_edges = Rwm.River_window_v1.Edges.none;
    }
  in
  Wayland.Proxy.Handler.attach river_seat
    object
      inherit [_] Rwm.River_seat_v1.v4
      method user_data = Seat_data seat
      method on_removed _ = seat.removed <- true

      method on_pointer_enter _ ~window =
        match Wayland.Proxy.user_data window with
        | Window_data w -> seat.hovered <- Some w
        | _ -> ()

      method on_pointer_leave _ = seat.hovered <- None

      method on_window_interaction _ ~window =
        match Wayland.Proxy.user_data window with
        | Window_data w -> seat.interacted <- Some w
        | _ -> ()

      method on_op_delta _ ~dx ~dy =
        seat.op_dx <- dx;
        seat.op_dy <- dy

      method on_op_release _ = seat.op_release <- true
      method on_wl_seat _ ~name = ()

      method on_shell_surface_interaction _ ~shell_surface =
        ()

      method on_pointer_position _ ~x ~y = ()
    end;
  wm.seats <- seat :: wm.seats
