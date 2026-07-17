open! Ocdwm_core
open! Ocdwm_layout
open! Ocdwm_state
open! Ocdwm_ops

let loop ~init_command ~net ~clock =
  Eio.Switch.run
  @@ fun sw ->
  let transport = Wayland.Unix_transport.connect ~sw ~net () in
  let display = Wayland.Client.connect ~sw transport in
  let registry = Wayland.Registry.of_display display in
  let wm_box : Wm.t Box.t = { body = None } in
  let river_wm_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Window_management.River_window_manager_v1.v4
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
         inherit [_] River.Xkb_bindings.River_xkb_bindings_v1.v2
       end
  in
  let river_lsh_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Layer_shell.River_layer_shell_v1.v1
       end
  in
  let river_input_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Input_management.River_input_manager_v1.v1
         method on_input_device _ device = Handlers.on_input_device device wm_box
         method on_finished = ignore
       end
  in
  let river_xkb_config_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] River.Xkb_config.River_xkb_config_v1.v1
         method on_xkb_keyboard _ xkb = Handlers.on_xkb_keyboard xkb wm_box
         method on_finished = ignore
       end
  in
  let layout_registry = Registry.create () in
  let config = Registry.default_layout_entry layout_registry |> Config.default in
  let wm : Wm.t =
    { river_wm_v1
    ; river_xkb_v1
    ; river_lsh_v1
    ; river_input_v1
    ; river_xkb_config_v1
    ; registry
    ; shutdown = Eio.Condition.create ()
    ; lifecycle = Running
    ; primary_seat = None
    ; is_dirty = false
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
    ; layout_registry
    ; ipc = Inactive
    }
  in
  let signaled = Eio.Condition.create () in
  let on_signal _ = Eio.Condition.broadcast signaled in
  Box.fill wm_box wm;
  Dirty.install (fun () ->
    River.Window_management.River_window_manager_v1.manage_dirty wm.river_wm_v1);
  Eio.Fiber.fork ~sw (fun () ->
    let outcome =
      Eio.Fiber.first
        (fun () ->
           Eio.Condition.await_no_mutex signaled;
           `Signal)
        (fun () ->
           Lifecycle.await_shutdown wm;
           `Shutdown)
    in
    match outcome with
    | `Signal -> Lifecycle.request_close wm
    | `Shutdown -> ());
  Sys.set_signal Sys.sigint @@ Sys.Signal_handle on_signal;
  Sys.set_signal Sys.sigterm @@ Sys.Signal_handle on_signal;
  Ipc_server.start ~sw ~net ~wm;
  Lifecycle.await_shutdown wm;
  Lifecycle.teardown ~clock wm;
  Wayland.Client.stop display;
  Exit.ok
;;
