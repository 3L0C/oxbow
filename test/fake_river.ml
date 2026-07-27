module Proxy = Wayland.Proxy
module Wl = Wayland.Wayland_server
module Wl_proto = Wayland.Wayland_proto
module Wm_server = River.Server.Window_management
module Wm_proto = River.Proto.Window_management
module Xkb_server = River.Server.Xkb.Bindings
module Xkb_proto = River.Proto.Xkb.Bindings
module Lsh_server = River.Server.Layer_shell
module Lsh_proto = River.Proto.Layer_shell
module Input_server = River.Server.Input
module Input_proto = River.Proto.Input
module Cfg_server = River.Server.Xkb.Config
module Cfg_proto = River.Proto.Xkb.Config

let output_width = 1920l
let output_height = 1080l

type phase =
  | Idle
  | In_manage
  | In_render

type t =
  { mutable phase : phase
  ; mutable trace : string list
  ; mutable manage_dirty_count : int
  ; mutable bindings : [ `V2 ] Xkb_server.River_xkb_binding_v1.t list
  ; mutable wm : [ `V4 ] Wm_server.River_window_manager_v1.t option
  ; mutable registry : [ `V1 ] Wl.Wl_registry.t option
  ; mutable next_global : int32
  ; mutable wl_outputs : (int32 * string) list
  ; mutable wl_seats : (int32 * string) list
  ; phase_done : Eio.Condition.t
  ; wm_ready : Eio.Condition.t
  }

let name_wm = 1l
let name_xkb_bindings = 2l
let name_layer_shell = 3l
let name_input_manager = 4l
let name_xkb_config = 5l

let sequence_bound =
  [ "propose_dimensions"
  ; "show"
  ; "hide"
  ; "fullscreen"
  ; "exit_fullscreen"
  ; "inform_fullscreen"
  ; "inform_not_fullscreen"
  ; "inform_maximized"
  ; "inform_unmaximized"
  ; "inform_resize_start"
  ; "inform_resize_end"
  ; "set_capabilities"
  ; "set_tiled"
  ; "use_csd"
  ; "use_ssd"
  ; "focus_window"
  ; "clear_focus"
  ; "op_start_pointer"
  ; "pointer_warp"
  ; "set_position"
  ; "place_top"
  ; "set_clip_box"
  ; "set_borders"
  ; "set_presentation_mode"
  ; "close"
  ; "op_end"
  ; "enable"
  ; "disable"
  ; "set_layout_override"
  ; "focus_shell_surface"
  ; "place_above"
  ; "place_below"
  ; "place_bottom"
  ; "set_content_clip_box"
  ; "set_dimension_bounds"
  ; "set_offset"
  ; "sync_next_commit"
  ]
;;

let record t name =
  match t.phase with
  | Idle ->
    if List.mem name sequence_bound then failwith ("request outside a sequence: " ^ name);
    t.trace <- ("idle:" ^ name) :: t.trace
  | In_manage -> t.trace <- ("manage:" ^ name) :: t.trace
  | In_render -> t.trace <- ("render:" ^ name) :: t.trace
;;

let finish_phase t =
  t.phase <- Idle;
  Eio.Condition.broadcast t.phase_done
;;

let node_handlers t =
  object
    inherit [_] Wm_server.River_node_v1.v4
    method on_set_position _ ~x:_ ~y:_ = record t "set_position"
    method on_place_top _ = record t "place_top"
    method on_place_bottom _ = record t "place_bottom"
    method on_place_below _ ~other:_ = record t "place_below"
    method on_place_above _ ~other:_ = record t "place_above"
    method on_destroy _ = record t "destroy"
  end
;;

let decoration_handlers t =
  object
    inherit [_] Wm_server.River_decoration_v1.v4
    method on_sync_next_commit _ = record t "sync_next_commit"
    method on_set_offset _ ~x:_ ~y:_ = record t "set_offset"
    method on_destroy _ = record t "destroy"
  end
;;

let output_handlers t =
  object
    inherit [_] Wm_server.River_output_v1.v4
    method on_set_presentation_mode _ ~mode:_ = record t "set_presentation_mode"
    method on_destroy _ = record t "destroy"
  end
;;

let pointer_binding_handlers t =
  object
    inherit [_] Wm_server.River_pointer_binding_v1.v4
    method on_enable _ = record t "enable"
    method on_disable _ = record t "disable"
    method on_destroy _ = record t "destroy"
  end
;;

let seat_handlers t =
  object
    inherit [_] Wm_server.River_seat_v1.v4
    method on_set_xcursor_theme _ ~name:_ ~size:_ = record t "set_xcursor_theme"
    method on_pointer_warp _ ~x:_ ~y:_ = record t "pointer_warp"
    method on_op_start_pointer _ = record t "op_start_pointer"
    method on_op_end _ = record t "op_end"
    method on_focus_window _ ~window:_ = record t "focus_window"
    method on_focus_shell_surface _ ~shell_surface:_ = record t "focus_shell_surface"
    method on_destroy _ = record t "destroy"
    method on_clear_focus _ = record t "clear_focus"

    method on_get_pointer_binding _ binding ~button:_ ~modifiers:_ =
      Proxy.Handler.attach binding (pointer_binding_handlers t);
      record t "get_pointer_binding"
  end
;;

let window_handlers t =
  object
    inherit [_] Wm_server.River_window_v1.v4
    method on_propose_dimensions _ ~width:_ ~height:_ = record t "propose_dimensions"
    method on_use_ssd _ = record t "use_ssd"
    method on_use_csd _ = record t "use_csd"
    method on_show _ = record t "show"
    method on_set_tiled _ ~edges:_ = record t "set_tiled"

    method on_set_dimension_bounds _ ~max_width:_ ~max_height:_ =
      record t "set_dimension_bounds"

    method on_set_content_clip_box _ ~x:_ ~y:_ ~width:_ ~height:_ =
      record t "set_content_clip_box"

    method on_set_clip_box _ ~x:_ ~y:_ ~width:_ ~height:_ = record t "set_clip_box"
    method on_set_capabilities _ ~caps:_ = record t "set_capabilities"
    method on_set_borders _ ~edges:_ ~width:_ ~r:_ ~g:_ ~b:_ ~a:_ = record t "set_borders"
    method on_inform_unmaximized _ = record t "inform_unmaximized"
    method on_inform_resize_start _ = record t "inform_resize_start"
    method on_inform_resize_end _ = record t "inform_resize_end"
    method on_inform_not_fullscreen _ = record t "inform_not_fullscreen"
    method on_inform_maximized _ = record t "inform_maximized"
    method on_inform_fullscreen _ = record t "inform_fullscreen"
    method on_hide _ = record t "hide"
    method on_fullscreen _ ~output:_ = record t "fullscreen"
    method on_exit_fullscreen _ = record t "exit_fullscreen"
    method on_destroy _ = record t "destroy"
    method on_close _ = record t "close"

    method on_get_node _ node =
      Proxy.Handler.attach node (node_handlers t);
      record t "get_node"

    method on_get_decoration_below _ decoration ~surface:_ =
      Proxy.Handler.attach decoration (decoration_handlers t);
      record t "get_decoration_below"

    method on_get_decoration_above _ decoration ~surface:_ =
      Proxy.Handler.attach decoration (decoration_handlers t);
      record t "get_decoration_above"
  end
;;

let shell_surface_handlers t =
  object
    inherit [_] Wm_server.River_shell_surface_v1.v4

    method on_get_node _ node =
      Proxy.Handler.attach node (node_handlers t);
      record t "get_node"

    method on_sync_next_commit _ = record t "sync_next_commit"
    method on_destroy _ = record t "destroy"
  end
;;

let wm_handlers t =
  (object
     inherit [_] Wm_server.River_window_manager_v1.v4
     method on_manage_finish _ = finish_phase t
     method on_render_finish _ = finish_phase t
     method on_manage_dirty _ = t.manage_dirty_count <- t.manage_dirty_count + 1
     method on_stop _ = ()
     method on_destroy _ = ()
     method on_exit_session _ = ()

     method on_get_shell_surface _ ss ~surface:_ =
       Proxy.Handler.attach ss (shell_surface_handlers t)
   end
    :> ([ `River_window_manager_v1 ], [ `V4 ], [ `Server ]) Proxy.Service_handler.t)
;;

let binding_handlers t =
  object
    inherit [_] Xkb_server.River_xkb_binding_v1.v2
    method on_enable _ = record t "enable"
    method on_disable _ = record t "disable"
    method on_set_layout_override _ ~layout:_ = record t "set_layout_override"
    method on_destroy _ = record t "destroy"
  end
;;

let bindings_seat_handlers t =
  object
    inherit [_] Xkb_server.River_xkb_bindings_seat_v1.v2
    method on_modifiers_watch _ ~modifiers:_ = record t "modifiers_watch"
    method on_ensure_next_key_eaten _ = record t "ensure_next_key_eaten"
    method on_cancel_ensure_next_key_eaten _ = record t "cancel_ensure_next_key_eaten"
    method on_destroy _ = record t "destroy"
  end
;;

let xkb_bindings_handlers t =
  (object
     inherit [_] Xkb_server.River_xkb_bindings_v1.v2
     method on_destroy _ = record t "destroy"

     method on_get_seat _ s ~seat:_ =
       Proxy.Handler.attach s (bindings_seat_handlers t);
       record t "get_seat"

     method on_get_xkb_binding _ ~seat:_ binding ~keysym:_ ~modifiers:_ =
       Proxy.Handler.attach binding (binding_handlers t);
       t.bindings <- t.bindings @ [ Proxy.cast_version binding ];
       record t "get_xkb_binding"
   end
    :> ([ `River_xkb_bindings_v1 ], [ `V2 ], [ `Server ]) Proxy.Service_handler.t)
;;

let layer_shell_output_handlers _t =
  object
    inherit [_] Lsh_server.River_layer_shell_output_v1.v1
    method on_set_default _ = ()
    method on_destroy _ = ()
  end
;;

let layer_shell_seat_handlers _t =
  object
    inherit [_] Lsh_server.River_layer_shell_seat_v1.v1
    method on_destroy _ = ()
  end
;;

let layer_shell_handlers t =
  (object
     inherit [_] Lsh_server.River_layer_shell_v1.v1
     method on_destroy _ = ()

     method on_get_output _ o ~output:_ =
       Proxy.Handler.attach o (layer_shell_output_handlers t);
       Lsh_server.River_layer_shell_output_v1.non_exclusive_area
         o
         ~x:0l
         ~y:0l
         ~width:output_width
         ~height:output_height

     method on_get_seat _ s ~seat:_ = Proxy.Handler.attach s (layer_shell_seat_handlers t)
   end
    :> ([ `River_layer_shell_v1 ], [ `V1 ], [ `Server ]) Proxy.Service_handler.t)
;;

let input_manager_handlers _t =
  (object
     inherit [_] Input_server.Management.River_input_manager_v1.v1
     method on_create_seat _ ~name:_ = ()
     method on_destroy_seat _ ~name:_ = ()
     method on_stop _ = ()
     method on_destroy _ = ()
   end
    :> ([ `River_input_manager_v1 ], [ `V1 ], [ `Server ]) Proxy.Service_handler.t)
;;

let keymap_handlers _t =
  object
    inherit [_] Cfg_server.River_xkb_keymap_v1.v1
    method on_destroy _ = ()
  end
;;

let xkb_config_handlers t =
  (object
     inherit [_] Cfg_server.River_xkb_config_v1.v1
     method on_stop _ = ()
     method on_destroy _ = ()

     method on_create_keymap _ keymap ~fd ~format:_ =
       Unix.close fd;
       Proxy.Handler.attach keymap (keymap_handlers t);
       Cfg_server.River_xkb_keymap_v1.success keymap
   end
    :> ([ `River_xkb_config_v1 ], [ `V1 ], [ `Server ]) Proxy.Service_handler.t)
;;

let wl_output_handlers _t =
  (object
     inherit [_] Wl.Wl_output.v4
     method on_release _ = ()
   end
    :> ([ `Wl_output ], [ `V4 ], [ `Server ]) Proxy.Service_handler.t)
;;

let wl_seat_handlers _t =
  (object
     inherit [_] Wl.Wl_seat.v9
     method on_get_pointer _ _ = ()
     method on_get_keyboard _ _ = ()
     method on_get_touch _ _ = ()
     method on_release _ = ()
   end
    :> ([ `Wl_seat ], [ `V9 ], [ `Server ]) Proxy.Service_handler.t)
;;

let registry_handlers t =
  object
    inherit [_] Wl.Wl_registry.v1

    method on_bind : type a. _ -> name:int32 -> (a, [ `Unknown ], _) Proxy.t -> unit =
      fun _ ~name proxy ->
        match Proxy.ty proxy with
        | Wm_proto.River_window_manager_v1.T ->
          let p =
            Proxy.Service_handler.attach_proxy proxy
            @@ Proxy.Service_handler.cast_version (wm_handlers t)
          in
          t.wm <- Some (Proxy.cast_version p);
          Eio.Condition.broadcast t.wm_ready
        | Xkb_proto.River_xkb_bindings_v1.T ->
          Proxy.Service_handler.attach proxy
          @@ Proxy.Service_handler.cast_version (xkb_bindings_handlers t)
        | Lsh_proto.River_layer_shell_v1.T ->
          Proxy.Service_handler.attach proxy
          @@ Proxy.Service_handler.cast_version (layer_shell_handlers t)
        | Input_proto.Management.River_input_manager_v1.T ->
          Proxy.Service_handler.attach proxy
          @@ Proxy.Service_handler.cast_version (input_manager_handlers t)
        | Cfg_proto.River_xkb_config_v1.T ->
          Proxy.Service_handler.attach proxy
          @@ Proxy.Service_handler.cast_version (xkb_config_handlers t)
        | Wl_proto.Wl_output.T ->
          let p =
            Proxy.Service_handler.attach_proxy proxy
            @@ Proxy.Service_handler.cast_version (wl_output_handlers t)
          in
          let p = Proxy.cast_version p in
          Wl.Wl_output.name p ~name:(List.assoc name t.wl_outputs);
          Wl.Wl_output.done_ p
        | Wl_proto.Wl_seat.T ->
          let p =
            Proxy.Service_handler.attach_proxy proxy
            @@ Proxy.Service_handler.cast_version (wl_seat_handlers t)
          in
          Wl.Wl_seat.name (Proxy.cast_version p) ~name:(List.assoc name t.wl_seats)
        | _ -> failwith "fake_river: bind of an interface the fake does not serve"
  end
;;

let announce t ~name ~interface ~version =
  match t.registry with
  | None -> failwith "fake_river: no registry yet"
  | Some reg -> Wl.Wl_registry.global reg ~name ~interface ~version
;;

let display_handlers t =
  object
    inherit [_] Wl.Wl_display.v1

    method on_sync _ cb =
      Proxy.Handler.attach cb (new Wl.Wl_callback.v1);
      Wl.Wl_callback.done_ cb ~callback_data:0l;
      Proxy.delete cb

    method on_get_registry _ reg =
      Proxy.Handler.attach reg (registry_handlers t);
      t.registry <- Some (Proxy.cast_version reg);
      announce
        t
        ~name:name_wm
        ~interface:Wm_proto.River_window_manager_v1.interface
        ~version:4l;
      announce
        t
        ~name:name_xkb_bindings
        ~interface:Xkb_proto.River_xkb_bindings_v1.interface
        ~version:2l;
      announce
        t
        ~name:name_layer_shell
        ~interface:Lsh_proto.River_layer_shell_v1.interface
        ~version:1l;
      announce
        t
        ~name:name_input_manager
        ~interface:Input_proto.Management.River_input_manager_v1.interface
        ~version:1l;
      announce
        t
        ~name:name_xkb_config
        ~interface:Cfg_proto.River_xkb_config_v1.interface
        ~version:1l
  end
;;

let start ~sw socket =
  let t =
    { phase = Idle
    ; trace = []
    ; manage_dirty_count = 0
    ; bindings = []
    ; wm = None
    ; registry = None
    ; next_global = 100l
    ; wl_outputs = []
    ; wl_seats = []
    ; phase_done = Eio.Condition.create ()
    ; wm_ready = Eio.Condition.create ()
    }
  in
  ignore
  @@ Wayland.Server.connect
       ~sw
       (Wayland.Unix_transport.of_socket socket)
       (display_handlers t);
  t
;;

let fresh_global t =
  let n = t.next_global in
  t.next_global <- Int32.add n 1l;
  n
;;

let await_idle t =
  while t.phase <> Idle do
    Eio.Condition.await_no_mutex t.phase_done
  done
;;

let await_wm t =
  while Option.is_none t.wm do
    Eio.Condition.await_no_mutex t.wm_ready
  done;
  Option.get t.wm
;;

let tick t =
  assert (t.phase = Idle);
  let wm = await_wm t in
  t.phase <- In_manage;
  Wm_server.River_window_manager_v1.manage_start wm;
  await_idle t;
  t.phase <- In_render;
  Wm_server.River_window_manager_v1.render_start wm;
  await_idle t
;;

let add_output t ~name =
  let wm = await_wm t in
  let global = fresh_global t in
  t.wl_outputs <- (global, name) :: t.wl_outputs;
  announce t ~name:global ~interface:Wl_proto.Wl_output.interface ~version:4l;
  let o = Wm_server.River_window_manager_v1.output wm (output_handlers t) in
  Wm_server.River_output_v1.position o ~x:0l ~y:0l;
  Wm_server.River_output_v1.dimensions o ~width:output_width ~height:output_height;
  Wm_server.River_output_v1.wl_output o ~name:global;
  tick t
;;

let add_seat t ~name =
  let wm = await_wm t in
  let global = fresh_global t in
  t.wl_seats <- (global, name) :: t.wl_seats;
  announce t ~name:global ~interface:Wl_proto.Wl_seat.interface ~version:9l;
  let s = Wm_server.River_window_manager_v1.seat wm (seat_handlers t) in
  Wm_server.River_seat_v1.wl_seat s ~name:global;
  tick t
;;

let add_window t ~app_id =
  let wm = await_wm t in
  let w = Wm_server.River_window_manager_v1.window wm (window_handlers t) in
  Wm_server.River_window_v1.app_id w ~app_id;
  Wm_server.River_window_v1.title w ~title:app_id;
  Wm_server.River_window_v1.dimensions w ~width:640l ~height:480l;
  tick t
;;

let press_binding t ~index =
  Xkb_server.River_xkb_binding_v1.pressed (List.nth t.bindings index)
;;

let trace t = List.rev t.trace
let manage_dirty_count t = t.manage_dirty_count
