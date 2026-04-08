module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
module Window_manager = Ocdwm_wm.Window_manager
module Exit = Ocdwm_core.Exit

let main ~net =
  Eio.Switch.run @@ fun sw ->
  let transport =
    Wayland.Unix_transport.connect ~sw ~net ()
  in
  let display = Wayland.Client.connect ~sw transport in
  let registry = Wayland.Registry.of_display display in
  let wm = Window_manager.create () in
  let window_manager =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Rwm.River_window_manager_v1.v4

         method on_unavailable =
           Window_manager.handle_unavailable

         method on_finished = Window_manager.handle_finished

         method on_manage_start proxy =
           Window_manager.handle_manage_start proxy wm

         method on_render_start proxy =
           Window_manager.handle_render_start proxy wm

         method on_session_locked =
           Window_manager.handle_session_locked

         method on_session_unlocked =
           Window_manager.handle_session_unlocked

         method on_window proxy river_window =
           Window_manager.handle_window proxy river_window
             wm

         method on_output proxy river_output =
           Window_manager.handle_output proxy river_output
             wm

         method on_seat proxy river_seat =
           Window_manager.handle_seat proxy river_seat wm
       end
  in
  let xkb_bindings =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Xkb.River_xkb_bindings_v1.v2
       end
  in
  wm.wm_v1 <- Some window_manager;
  wm.xkb_v1 <- Some xkb_bindings;
  ()

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.(set_level (Some Info));
  Printexc.record_backtrace true;
  (* Unix.putenv "WAYLAND_DEBUG" ""; *)
  try Eio_main.run @@ fun env -> main ~net:env#net with
  | Failure s -> begin
      Printf.eprintf "%s\n" s;
      Exit.unavailable ()
    end
  | Window_manager.Unavailable -> Exit.unavailable ()
  | Window_manager.Finished -> Exit.ok ()
