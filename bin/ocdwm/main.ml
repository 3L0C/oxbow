module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
module Wayland_handlers = Ocdwm_wm.Wayland_handlers
module Types = Ocdwm_wm.Types
module Exit = Ocdwm_core.Exit
module Config = Ocdwm_wm.Config
module Layout = Ocdwm_wm.Layout
module Box = Ocdwm_wm.Box
module Wm_exceptions = Ocdwm_wm.Exceptions

let main ~net =
  Eio.Switch.run
  @@ fun sw ->
  let transport = Wayland.Unix_transport.connect ~sw ~net () in
  let display = Wayland.Client.connect ~sw transport in
  let registry = Wayland.Registry.of_display display in
  let wm_box : Types.Window_manager.t Box.t = { body = None } in
  let river_wm_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Rwm.River_window_manager_v1.v4
         method on_finished = Wayland_handlers.on_finished
         method on_manage_start proxy = Wayland_handlers.on_manage_start proxy wm_box

         method on_output proxy river_output =
           Wayland_handlers.on_output proxy river_output wm_box

         method on_render_start proxy = Wayland_handlers.on_render_start proxy wm_box

         method on_seat proxy river_seat =
           Wayland_handlers.on_seat proxy river_seat wm_box

         method on_session_locked = Wayland_handlers.on_session_locked
         method on_session_unlocked = Wayland_handlers.on_session_unlocked
         method on_unavailable = Wayland_handlers.on_unavailable

         method on_window proxy river_window =
           Wayland_handlers.on_window proxy river_window wm_box
       end
  in
  let river_xkb_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Xkb.River_xkb_bindings_v1.v2
       end
  in
  let river_lsh_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Rlsh.River_layer_shell_v1.v1
       end
  in
  let layout_registry = Layout.create_registry () in
  let config = Layout.default_layout_entry ~registry:layout_registry |> Config.default in
  let wm =
    Types.Window_manager.
      { river_wm_v1
      ; river_xkb_v1
      ; river_lsh_v1
      ; registry
      ; focused_output = None
      ; dirty = false
      ; outputs = []
      ; windows = []
      ; seats = []
      ; config
      ; config_loaded = true
      ; layout_registry
      ; ipc = Ipc_inactive
      }
  in
  wm_box.body <- Some wm;
  Ocdwm_wm.Ipc_server.start ~sw ~net ~wm
;;

let setup () =
  Sys.catch_break true;
  Sys.set_signal Sys.sigchld Sys.Signal_ignore;
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.(set_level (Some Info));
  (* Unix.putenv "WAYLAND_DEBUG" "1"; *)
  Printexc.record_backtrace true
;;

let () =
  setup ();
  try Eio_main.run @@ fun env -> main ~net:env#net with
  | Sys.Break -> Exit.ok ()
  | Failure s ->
    Printf.eprintf "%s\n" s;
    Exit.unavailable ()
  | Wm_exceptions.Unavailable -> Exit.unavailable ()
  | Wm_exceptions.Finished -> Exit.ok ()
;;
