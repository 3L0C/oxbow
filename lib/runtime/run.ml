open! Oxbow_core
open! Oxbow_state

let loop ?socket_path ?transport:trans ?on_display ~init_command ~net ~clock () =
  Eio.Switch.run
  @@ fun sw ->
  let transport =
    match trans with
    | Some t -> t
    | None -> Wayland.Unix_transport.connect ~sw ~net ()
  in
  let display = Wayland.Client.connect ~sw transport in
  Option.iter (fun f -> f display) on_display;
  let registry = Wayland.Registry.of_display display in
  Handlers.registry := Some registry;
  let wm_box : Wm.t Box.t = { body = None } in
  let river_wm_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Obj.Window_management.Client.t
         method on_finished _ = Handlers.on_finished wm_box
         method on_manage_start proxy = Handlers.on_manage_start proxy wm_box

         method on_output proxy river_output =
           Handlers.on_output proxy river_output wm_box

         method on_render_start proxy = Handlers.on_render_start proxy wm_box
         method on_seat proxy river_seat = Handlers.on_seat proxy river_seat wm_box
         method on_session_locked proxy = Handlers.on_session_locked proxy wm_box
         method on_session_unlocked proxy = Handlers.on_session_unlocked proxy wm_box
         method on_unavailable = Handlers.on_unavailable

         method on_window proxy river_window =
           Handlers.on_window proxy river_window wm_box
       end
  in
  let river_xkb_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Obj.Xkb.Bindings.Client.t
       end
  in
  let river_lsh_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Obj.Layer_shell.Client.t
       end
  in
  let river_input_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Obj.Input.Management.Client.t
         method on_input_device _ device = Handlers.on_input_device device wm_box
         method on_finished = ignore
       end
  in
  let river_libinput_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Obj.Input.Config.Client.t
         method on_libinput_device _ device = Handlers.on_libinput_device device wm_box
         method on_finished = ignore
       end
  in
  let river_xkb_config_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Obj.Xkb.Config.Client.t
         method on_xkb_keyboard _ xkb = Handlers.on_xkb_keyboard xkb wm_box
         method on_finished = ignore
       end
  in
  let config = Config.default () in
  let wm : Wm.t =
    { river_wm_v1
    ; river_xkb_v1
    ; river_lsh_v1
    ; river_input_v1
    ; river_libinput_v1
    ; river_xkb_config_v1
    ; shutdown = Eio.Condition.create ()
    ; lifecycle = Running
    ; primary_seat = None
    ; session_locked = false
    ; outputs = []
    ; windows = []
    ; seats = []
    ; input_devices = []
    ; xkb_stash = []
    ; keymap = None
    ; desired_keymap_path = None
    ; config
    ; init_command
    ; init_handle = None
    ; ipc = { subscribers = []; last = [] }
    }
  in
  let signaled = Eio.Condition.create () in
  let on_signal _ = Eio.Condition.broadcast signaled in
  Box.fill wm_box wm;
  Schedule.install (fun () -> Emit.manage_dirty wm.river_wm_v1);
  Eio.Fiber.fork_daemon ~sw (fun () ->
    Eio.Condition.await_no_mutex signaled;
    Lifecycle.request_close wm;
    `Stop_daemon);
  Sys.set_signal Sys.sigint @@ Sys.Signal_handle on_signal;
  Sys.set_signal Sys.sigterm @@ Sys.Signal_handle on_signal;
  Ipc_server.start ?socket_path ~sw ~net ~wm ();
  Lifecycle.await_shutdown wm;
  Lifecycle.teardown ~clock wm;
  Wayland.Client.stop display;
  Exit.ok
;;
