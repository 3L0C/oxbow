module Proxy = Wayland.Proxy
module Wl = Wayland.Wayland_server
module Wl_proto = Wayland.Wayland_proto
module Wm_server = River.Server.Window_management
module Wm_proto = River.Proto.Window_management
module Xkb_server = River.Server.Xkb.Bindings
module Xkb_proto = River.Proto.Xkb.Bindings
module Lsh_server = River.Server.Layer_shell
module Lsh_proto = River.Proto.Layer_shell
module Input_proto = River.Proto.Input
module Cfg_server = River.Server.Xkb.Config
module Cfg_proto = River.Proto.Xkb.Config

type window = River.Obj.Window_management.v Wm_server.River_window_v1.t
type output = River.Obj.Window_management.v Wm_server.River_output_v1.t
type seat = River.Obj.Window_management.v Wm_server.River_seat_v1.t

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
  ; mutable bindings : River.Obj.Xkb.Bindings.v Xkb_server.River_xkb_binding_v1.t list
  ; mutable wm : River.Obj.Window_management.v Wm_server.River_window_manager_v1.t option
  ; mutable registry : [ `V1 ] Wl.Wl_registry.t option
  ; mutable next_global : int32
  ; mutable wl_outputs : (int32 * string) list
  ; mutable wl_seats : (int32 * string) list
  ; mutable dirty : bool
  ; mutable windows :
      (string option * River.Obj.Window_management.v Wm_server.River_window_v1.t) list
  ; mutable seats :
      (string * River.Obj.Window_management.v Wm_server.River_seat_v1.t) list
  ; mutable outputs :
      (string * River.Obj.Window_management.v Wm_server.River_output_v1.t) list
  ; mutable output_positions : (int32 * (int32 * int32)) list
  ; mutable owners : (int32 * string) list
  ; mutable app_counts : (string * int) list
  ; phase_done : Eio.Condition.t
  ; wm_ready : Eio.Condition.t
  }

let name_wm = 1l
let name_xkb_bindings = 2l
let name_layer_shell = 3l
let name_input_manager = 4l
let name_libinput_manager = 5l
let name_xkb_config = 6l

let manage_only =
  [ "close"
  ; "propose_dimensions"
  ; "use_csd"
  ; "use_ssd"
  ; "set_tiled"
  ; "inform_resize_start"
  ; "inform_resize_end"
  ; "set_capabilities"
  ; "inform_maximized"
  ; "inform_unmaximized"
  ; "inform_fullscreen"
  ; "inform_not_fullscreen"
  ; "fullscreen"
  ; "exit_fullscreen"
  ; "set_dimension_bounds"
  ; "focus_window"
  ; "focus_shell_surface"
  ; "clear_focus"
  ; "op_start_pointer"
  ; "op_end"
  ; "pointer_warp"
  ; "enable"
  ; "disable"
  ]
;;

let render_only =
  [ "hide"
  ; "show"
  ; "set_borders"
  ; "set_clip_box"
  ; "set_content_clip_box"
  ; "set_offset"
  ; "sync_next_commit"
  ; "set_position"
  ; "place_top"
  ; "place_bottom"
  ; "place_above"
  ; "place_below"
  ; "set_presentation_mode"
  ]
;;

let record t name =
  let base =
    match String.index_opt name '(' with
    | Some i -> String.sub name 0 i
    | None -> name
  in
  match t.phase with
  | Idle ->
    if List.mem base manage_only || List.mem base render_only
    then failwith ("request outside a sequence: " ^ name);
    t.trace <- ("idle:" ^ name) :: t.trace
  | In_manage ->
    if List.mem base render_only
    then failwith ("render request in a manage sequence: " ^ name);
    t.trace <- ("manage:" ^ name) :: t.trace
  | In_render ->
    if List.mem base manage_only
    then failwith ("manage request in a render sequence: " ^ name);
    t.trace <- ("render:" ^ name) :: t.trace
;;

let finish_phase t =
  t.phase <- Idle;
  Eio.Condition.broadcast t.phase_done
;;

let label t p =
  let id = Proxy.id p in
  match List.assoc_opt id t.owners with
  | Some owner -> owner
  | None ->
    (match List.find_opt (fun (_, w) -> Proxy.id w = id) t.windows with
     | Some (Some app_id, _) -> app_id
     | _ -> "?")
;;

let adopt t p ~owner = t.owners <- (Proxy.id p, owner) :: t.owners
let recordl t p name = record t (Printf.sprintf "%s(%s)" name (label t p))

let recordf t p name fmt =
  Printf.ksprintf
    (fun args -> record t (Printf.sprintf "%s(%s, %s)" name (label t p) args))
    fmt
;;

let node_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.node
    method on_set_position n ~x ~y = recordf t n "set_position" "%ld, %ld" x y
    method on_place_top n = recordl t n "place_top"
    method on_place_bottom n = recordl t n "place_bottom"
    method on_place_below n ~other = recordf t n "place_below" "%s" (label t other)
    method on_place_above n ~other = recordf t n "place_above" "%s" (label t other)
    method on_destroy n = recordl t n "destroy"
  end
;;

let decoration_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.decoration
    method on_sync_next_commit d = recordl t d "sync_next_commit"
    method on_set_offset d ~x ~y = recordf t d "set_offset" "%ld, %ld" x y
    method on_destroy d = recordl t d "destroy"
  end
;;

let output_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.output

    method on_set_presentation_mode o ~mode =
      let mode_name =
        match mode with
        | Vsync -> "vsync"
        | Async -> "async"
      in
      recordf t o "set_presentation_mode" "%s" mode_name

    method on_destroy _ = record t "destroy"
  end
;;

let pointer_binding_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.pointer_binding
    method on_enable b = recordl t b "enable"
    method on_disable b = recordl t b "disable"
    method on_destroy b = recordl t b "destroy"
  end
;;

let seat_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.seat

    method on_set_xcursor_theme s ~name ~size =
      recordf t s "set_xcursor_theme" "%s, %ldpx" name size

    method on_pointer_warp s ~x ~y = recordf t s "pointer_warp" "(%ld, %ld)" x y
    method on_op_start_pointer s = recordl t s "op_start_pointer"
    method on_op_end s = recordl t s "op_end"
    method on_focus_window s ~window = recordf t s "focus_window" "%s" (label t window)

    method on_focus_shell_surface s ~shell_surface =
      recordf t s "focus_shell_surface" "%s" (label t shell_surface)

    method on_destroy s = recordl t s "destroy"
    method on_clear_focus s = recordl t s "clear_focus"

    method on_get_pointer_binding s binding ~button ~modifiers =
      Proxy.Handler.attach binding (pointer_binding_handlers t);
      adopt t binding ~owner:(Printf.sprintf "btn=%ld, mods=0x%lx" button modifiers);
      recordf t s "get_pointer_binding" "btn=%ld, mods=0x%lx" button modifiers
  end
;;

let window_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.window

    method on_propose_dimensions w ~width ~height =
      recordf t w "propose_dimensions" "%ldx%ld" width height

    method on_use_ssd w = recordl t w "use_ssd"
    method on_use_csd w = recordl t w "use_csd"
    method on_show w = recordl t w "show"
    method on_set_tiled w ~edges = recordf t w "set_tiled" "edges=0x%lx" edges

    method on_set_dimension_bounds w ~max_width ~max_height =
      recordf t w "set_dimension_bounds" "%ldx%ld" max_width max_height

    method on_set_content_clip_box w ~x ~y ~width ~height =
      recordf t w "set_content_clip_box" "%ld, %ld, %ldx%ld" x y width height

    method on_set_clip_box w ~x ~y ~width ~height =
      recordf t w "set_clip_box" "%ld, %ld, %ldx%ld" x y width height

    method on_set_capabilities w ~caps = recordf t w "set_capabilities" "caps=0x%lx" caps

    method on_set_borders w ~edges ~width ~r ~g ~b ~a =
      recordf
        t
        w
        "set_borders"
        "edges=0x%lx, w=%ld, rgba=%lx %lx %lx %lx"
        edges
        width
        r
        g
        b
        a

    method on_inform_unmaximized w = recordl t w "inform_unmaximized"
    method on_inform_resize_start w = recordl t w "inform_resize_start"
    method on_inform_resize_end w = recordl t w "inform_resize_end"
    method on_inform_not_fullscreen w = recordl t w "inform_not_fullscreen"
    method on_inform_maximized w = recordl t w "inform_maximized"
    method on_inform_fullscreen w = recordl t w "inform_fullscreen"
    method on_hide w = recordl t w "hide"
    method on_fullscreen w ~output:_ = recordl t w "fullscreen"
    method on_exit_fullscreen w = recordl t w "exit_fullscreen"
    method on_destroy w = recordl t w "destroy"
    method on_close w = recordl t w "close"

    method on_get_node w node =
      Proxy.Handler.attach node (node_handlers t);
      adopt t node ~owner:(label t w);
      recordl t w "get_node"

    method on_get_decoration_below w decoration ~surface:_ =
      Proxy.Handler.attach decoration (decoration_handlers t);
      adopt t decoration ~owner:(label t w);
      recordl t w "get_decoration_below"

    method on_get_decoration_above w decoration ~surface:_ =
      Proxy.Handler.attach decoration (decoration_handlers t);
      adopt t decoration ~owner:(label t w);
      recordl t w "get_decoration_above"
  end
;;

let shell_surface_handlers t =
  object
    inherit [_] River.Obj.Window_management.Server.shell_surface

    method on_get_node w node =
      Proxy.Handler.attach node (node_handlers t);
      adopt t node ~owner:"shell";
      recordl t w "get_node"

    method on_sync_next_commit _ = record t "sync_next_commit"
    method on_destroy _ = record t "destroy"
  end
;;

let wm_handlers t =
  (object
     inherit [_] River.Obj.Window_management.Server.t
     method on_manage_finish _ = finish_phase t
     method on_render_finish _ = finish_phase t

     method on_manage_dirty _ =
       t.manage_dirty_count <- t.manage_dirty_count + 1;
       t.dirty <- true

     method on_stop _ = ()
     method on_destroy _ = ()
     method on_exit_session _ = ()

     method on_get_shell_surface _ ss ~surface:_ =
       Proxy.Handler.attach ss (shell_surface_handlers t);
       adopt t ss ~owner:"shell"
   end
    :> ( [ `River_window_manager_v1 ]
         , River.Obj.Window_management.v
         , [ `Server ] )
         Proxy.Service_handler.t)
;;

let binding_handlers t =
  object
    inherit [_] River.Obj.Xkb.Bindings.Server.binding
    method on_enable b = recordl t b "enable"
    method on_disable b = recordl t b "disable"
    method on_set_layout_override b ~layout:_ = recordl t b "set_layout_override"
    method on_destroy b = recordl t b "destroy"
  end
;;

let bindings_seat_handlers t =
  object
    inherit [_] River.Obj.Xkb.Bindings.Server.seat
    method on_modifiers_watch _ ~modifiers:_ = record t "modifiers_watch"
    method on_ensure_next_key_eaten _ = record t "ensure_next_key_eaten"
    method on_cancel_ensure_next_key_eaten _ = record t "cancel_ensure_next_key_eaten"
    method on_destroy _ = record t "destroy"
  end
;;

let xkb_bindings_handlers t =
  (object
     inherit [_] River.Obj.Xkb.Bindings.Server.t
     method on_destroy _ = record t "destroy"

     method on_get_seat _ s ~seat:_ =
       Proxy.Handler.attach s (bindings_seat_handlers t);
       record t "get_seat"

     method on_get_xkb_binding _ ~seat:_ binding ~keysym ~modifiers =
       Proxy.Handler.attach binding (binding_handlers t);
       adopt t binding ~owner:(Printf.sprintf "key=0x%lx, mods=0x%lx" keysym modifiers);
       t.bindings <- t.bindings @ [ Proxy.cast_version binding ];
       recordl t binding "get_xkb_binding"
   end
    :> ( [ `River_xkb_bindings_v1 ]
         , River.Obj.Xkb.Bindings.v
         , [ `Server ] )
         Proxy.Service_handler.t)
;;

let layer_shell_output_handlers _t =
  object
    inherit [_] River.Obj.Layer_shell.Server.output
    method on_set_default _ = ()
    method on_destroy _ = ()
  end
;;

let layer_shell_seat_handlers _t =
  object
    inherit [_] River.Obj.Layer_shell.Server.seat
    method on_destroy _ = ()
  end
;;

let layer_shell_handlers t =
  (object
     inherit [_] River.Obj.Layer_shell.Server.t
     method on_destroy _ = ()

     method on_get_output _ o ~output =
       Proxy.Handler.attach o (layer_shell_output_handlers t);
       let x, y =
         List.assoc_opt (Proxy.id output) t.output_positions
         |> Option.value ~default:(0l, 0l)
       in
       Lsh_server.River_layer_shell_output_v1.non_exclusive_area
         o
         ~x
         ~y
         ~width:output_width
         ~height:output_height

     method on_get_seat _ s ~seat:_ = Proxy.Handler.attach s (layer_shell_seat_handlers t)
   end
    :> ( [ `River_layer_shell_v1 ]
         , River.Obj.Layer_shell.v
         , [ `Server ] )
         Proxy.Service_handler.t)
;;

let input_manager_handlers _t =
  (object
     inherit [_] River.Obj.Input.Management.Server.t
     method on_create_seat _ ~name:_ = ()
     method on_destroy_seat _ ~name:_ = ()
     method on_stop _ = ()
     method on_destroy _ = ()
   end
    :> ( [ `River_input_manager_v1 ]
         , River.Obj.Input.Management.v
         , [ `Server ] )
         Proxy.Service_handler.t)
;;

let libinput_manager_handlers _t =
  (object
     inherit [_] River.Obj.Input.Config.Server.t
     method on_create_accel_config _ _ ~profile:_ = ()
     method on_stop _ = ()
     method on_destroy _ = ()
   end
    :> ( [ `River_libinput_config_v1 ]
         , River.Obj.Input.Config.v
         , [ `Server ] )
         Proxy.Service_handler.t)
;;

let keymap_handlers _t =
  object
    inherit [_] River.Obj.Xkb.Config.Server.keymap
    method on_destroy _ = ()
  end
;;

let xkb_config_handlers t =
  (object
     inherit [_] River.Obj.Xkb.Config.Server.t
     method on_stop _ = ()
     method on_destroy _ = ()

     method on_create_keymap _ keymap ~fd ~format:_ =
       Unix.close fd;
       Proxy.Handler.attach keymap (keymap_handlers t);
       Cfg_server.River_xkb_keymap_v1.success keymap
   end
    :> ( [ `River_xkb_config_v1 ]
         , River.Obj.Xkb.Config.v
         , [ `Server ] )
         Proxy.Service_handler.t)
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
        | Input_proto.Config.River_libinput_config_v1.T ->
          Proxy.Service_handler.attach proxy
          @@ Proxy.Service_handler.cast_version (libinput_manager_handlers t)
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
        ~version:River.Obj.Window_management.version;
      announce
        t
        ~name:name_xkb_bindings
        ~interface:Xkb_proto.River_xkb_bindings_v1.interface
        ~version:River.Obj.Xkb.Bindings.version;
      announce
        t
        ~name:name_layer_shell
        ~interface:Lsh_proto.River_layer_shell_v1.interface
        ~version:River.Obj.Layer_shell.version;
      announce
        t
        ~name:name_input_manager
        ~interface:Input_proto.Management.River_input_manager_v1.interface
        ~version:River.Obj.Input.Management.version;
      announce
        t
        ~name:name_libinput_manager
        ~interface:Input_proto.Config.River_libinput_config_v1.interface
        ~version:River.Obj.Input.Config.version;
      announce
        t
        ~name:name_xkb_config
        ~interface:Cfg_proto.River_xkb_config_v1.interface
        ~version:River.Obj.Xkb.Config.version
  end
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
  while t.phase <> Idle do
    Eio.Fiber.yield ()
  done;
  let wm = await_wm t in
  t.phase <- In_manage;
  Wm_server.River_window_manager_v1.manage_start wm;
  await_idle t;
  t.phase <- In_render;
  Wm_server.River_window_manager_v1.render_start wm;
  await_idle t
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
    ; dirty = false
    ; windows = []
    ; seats = []
    ; outputs = []
    ; output_positions = []
    ; owners = []
    ; app_counts = []
    ; phase_done = Eio.Condition.create ()
    ; wm_ready = Eio.Condition.create ()
    }
  in
  ignore
  @@ Wayland.Server.connect
       ~sw
       (Wayland.Unix_transport.of_socket socket)
       (display_handlers t);
  Eio.Fiber.fork ~sw (fun () ->
    while true do
      if t.dirty && t.phase = Idle
      then (
        t.dirty <- false;
        tick t)
      else Eio.Fiber.yield ()
    done);
  t
;;

let spawn_output ?(x = 0l) ?(y = 0l) t ~name =
  let wm = await_wm t in
  let global = fresh_global t in
  t.wl_outputs <- (global, name) :: t.wl_outputs;
  announce t ~name:global ~interface:Wl_proto.Wl_output.interface ~version:4l;
  let o = Wm_server.River_window_manager_v1.output wm (output_handlers t) in
  adopt t o ~owner:name;
  Wm_server.River_output_v1.position o ~x ~y;
  t.output_positions <- (Proxy.id o, (x, y)) :: t.output_positions;
  Wm_server.River_output_v1.dimensions o ~width:output_width ~height:output_height;
  Wm_server.River_output_v1.wl_output o ~name:global;
  t.outputs <- (name, o) :: t.outputs;
  tick t;
  o
;;

let add_output ?x ?y t ~name = spawn_output ?x ?y t ~name |> ignore

let remove_output t o =
  t.outputs <- List.filter (fun (_, o') -> Proxy.id o' <> Proxy.id o) t.outputs;
  t.output_positions <- List.remove_assoc (Proxy.id o) t.output_positions;
  Wm_server.River_output_v1.removed o;
  tick t
;;

let spawn_seat t ~name =
  let wm = await_wm t in
  let global = fresh_global t in
  t.wl_seats <- (global, name) :: t.wl_seats;
  announce t ~name:global ~interface:Wl_proto.Wl_seat.interface ~version:9l;
  let s = Wm_server.River_window_manager_v1.seat wm (seat_handlers t) in
  adopt t s ~owner:name;
  Wm_server.River_seat_v1.wl_seat s ~name:global;
  t.seats <- (name, s) :: t.seats;
  tick t;
  s
;;

let add_seat t ~name = spawn_seat t ~name |> ignore

let remove_seat t s =
  t.seats <- List.filter (fun (_, s') -> Proxy.id s' <> Proxy.id s) t.seats;
  Wm_server.River_seat_v1.removed s;
  tick t
;;

let spawn_window ?pid t ~app_id =
  let wm = await_wm t in
  let w = Wm_server.River_window_manager_v1.window wm (window_handlers t) in
  let base = Option.value ~default:"?" app_id in
  let live = List.length (List.filter (fun (a, _) -> a = app_id) t.windows) in
  let count =
    if live = 0 then 1 else 1 + Option.value ~default:1 (List.assoc_opt base t.app_counts)
  in
  t.app_counts <- (base, count) :: List.remove_assoc base t.app_counts;
  let owner = if count = 1 then base else base ^ "#" ^ string_of_int count in
  adopt t w ~owner;
  t.windows <- (app_id, w) :: t.windows;
  Wm_server.River_window_v1.app_id w ~app_id;
  Option.iter
    (fun p -> Wm_server.River_window_v1.unreliable_pid w ~unreliable_pid:(Int32.of_int p))
    pid;
  Wm_server.River_window_v1.title w ~title:app_id;
  Wm_server.River_window_v1.dimensions w ~width:640l ~height:480l;
  tick t;
  w
;;

let close t w =
  t.windows <- List.filter (fun (_, w') -> Proxy.id w' <> Proxy.id w) t.windows;
  Wm_server.River_window_v1.closed w;
  tick t
;;

let window_named t ~app_id =
  match List.assoc_opt app_id t.windows with
  | None -> failwith "fake_river: no window with this app_id"
  | Some w -> w
;;

let output_named t ~name =
  match List.assoc_opt name t.outputs with
  | None -> failwith "fake_river: no output with this name"
  | Some o -> o
;;

let seat_named t ~seat =
  match List.assoc_opt seat t.seats with
  | None -> failwith "fake_river: no seat with this name"
  | Some s -> s
;;

let send_dimensions_hint t ~app_id ~min_w ~min_h ~max_w ~max_h =
  Wm_server.River_window_v1.dimensions_hint
    (window_named t ~app_id)
    ~min_width:min_w
    ~min_height:min_h
    ~max_width:max_w
    ~max_height:max_h;
  tick t
;;

let send_dimensions t ~app_id ~width ~height =
  Wm_server.River_window_v1.dimensions (window_named t ~app_id) ~width ~height;
  tick t
;;

let send_capture_sessions t ~app_id ~count =
  Wm_server.River_window_v1.capture_sessions (window_named t ~app_id) ~count;
  tick t
;;

let send_output_capture_sessions t ~name ~count =
  Wm_server.River_output_v1.capture_sessions (output_named t ~name) ~count;
  tick t
;;

let send_pointer_enter t ~seat ~app_id =
  Wm_server.River_seat_v1.pointer_enter
    (seat_named t ~seat)
    ~window:(window_named t ~app_id);
  tick t
;;

let send_pointer_position t ~seat ~x ~y =
  Wm_server.River_seat_v1.pointer_position (seat_named t ~seat) ~x ~y;
  tick t
;;

let send_pointer_hover t ~seat ~app_id ~x ~y =
  Wm_server.River_seat_v1.pointer_enter
    (seat_named t ~seat)
    ~window:(window_named t ~app_id);
  Wm_server.River_seat_v1.pointer_position (seat_named t ~seat) ~x ~y;
  tick t
;;

let send_op_delta t ~seat ~dx ~dy =
  Wm_server.River_seat_v1.op_delta (seat_named t ~seat) ~dx ~dy;
  tick t
;;

let send_op_release t ~seat =
  Wm_server.River_seat_v1.op_release (seat_named t ~seat);
  tick t
;;

let press_binding t ~index =
  Xkb_server.River_xkb_binding_v1.pressed (List.nth t.bindings index)
;;

let trace t = List.rev t.trace
let manage_dirty_count t = t.manage_dirty_count
let binding_count t = List.length t.bindings
let idle t = t.phase = Idle && not t.dirty
