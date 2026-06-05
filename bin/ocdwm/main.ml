module Box = Ocdwm_wm.Box
module Cli = Ocdwm_core.Cli
module Config = Ocdwm_wm.Config
module Exit = Ocdwm_core.Exit
module Init_script = Ocdwm_wm.Init_script
module Layout = Ocdwm_wm.Layout
module Rinput = Ocdwm_protocol.River_input_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rxkb = Ocdwm_protocol.River_xkb_config_v1_client
module Types = Ocdwm_wm.Types
module Wayland_handlers = Ocdwm_wm.Wayland_handlers
module Window_manager = Ocdwm_wm.Window_manager
module Window_manager_state = Ocdwm_wm.Window_manager_state
module Wm_exceptions = Ocdwm_wm.Exceptions
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client

let version =
  match Build_info.V1.version () with
  | Some v -> Build_info.V1.Version.to_string v
  | None -> "dev"
;;

let loop ~init_command ~net ~clock =
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
         method on_finished _ = Wayland_handlers.on_finished wm_box
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
  let river_input_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Rinput.River_input_manager_v1.v1
         method on_input_device _ device = Wayland_handlers.on_input_device device wm_box
         method on_finished = ignore
       end
  in
  let river_xkb_config_v1 =
    Wayland.Registry.bind registry
    @@ object
         inherit [_] Rxkb.River_xkb_config_v1.v1
         method on_xkb_keyboard _ xkb = Wayland_handlers.on_xkb_keyboard xkb wm_box
         method on_finished = ignore
       end
  in
  let layout_registry = Layout.create_registry () in
  let config = Layout.default_layout_entry ~registry:layout_registry |> Config.default in
  let wm =
    Types.Window_manager.
      { river_wm_v1
      ; river_xkb_v1
      ; river_lsh_v1
      ; river_input_v1
      ; river_xkb_config_v1
      ; registry
      ; shutdown = Eio.Condition.create ()
      ; state = Wm_running
      ; primary_seat = None
      ; dirty = false
      ; outputs = []
      ; windows = []
      ; seats = []
      ; input_devices = []
      ; current_keymap = None
      ; desired_keymap_path = None
      ; config
      ; init_command
      ; init_handle = None
      ; layout_registry
      ; ipc = Ipc_inactive
      }
  in
  let signaled = Eio.Condition.create () in
  let on_signal _ = Eio.Condition.broadcast signaled in
  wm_box.body <- Some wm;
  Eio.Fiber.fork ~sw (fun () ->
    let outcome =
      Eio.Fiber.first
        (fun () ->
           Eio.Condition.await_no_mutex signaled;
           `Signal)
        (fun () ->
           Window_manager.await_shutdown wm;
           `Shutdown)
    in
    match outcome with
    | `Signal -> Window_manager.request_close wm
    | `Shutdown -> ());
  Sys.set_signal Sys.sigint @@ Sys.Signal_handle on_signal;
  Sys.set_signal Sys.sigterm @@ Sys.Signal_handle on_signal;
  Ocdwm_wm.Ipc_server.start ~sw ~net ~wm;
  Window_manager.await_shutdown wm;
  Window_manager.teardown ~clock wm;
  Wayland.Client.stop display;
  Exit.ok
;;

let setup ~log_level =
  Logs.set_reporter @@ Logs_fmt.reporter ();
  Logs.(set_level (Some log_level));
  Sys.set_signal Sys.sigchld Sys.Signal_ignore;
  Printexc.record_backtrace true
;;

let run ~init_command ~log_level () =
  setup ~log_level;
  try Eio_main.run @@ fun env -> loop ~init_command ~net:env#net ~clock:env#clock with
  | Failure s ->
    Printf.eprintf "%s\n" s;
    Exit.software
  | Wm_exceptions.Unavailable -> Exit.unavailable
;;

let man =
  let open Cmdliner in
  [ `S Manpage.s_synopsis
  ; `S Manpage.s_options
  ; `S Manpage.s_common_options
  ; `S "CONFIGURATION"
  ; `P
      "On startup $(mname) runs an init script that issues $(b,ocdwmctl)(1) commands to \
       set keybindings, layouts, and window rules. The script is located by checking, in \
       order:"
  ; `I
      ( "1."
      , "The $(b,-c) $(i,SHELL_COMMAND) argument. If given, $(i,SHELL_COMMAND) is run \
         literally via $(b,/bin/sh -c) with no path search;" )
  ; `Noblank
  ; `I ("2.", "$(b,\\$XDG_CONFIG_HOME/ocdwm/init), if executable;")
  ; `Noblank
  ; `I ("3.", "$(b,\\$HOME/.config/ocdwm/init), if executable;")
  ; `P "If none are found or executable, $(mname) starts with only built-in keybindings."
  ; `P
      "The script runs in its own session via $(b,setsid)(2), after the river protocols \
       are bound, so $(b,ocdwmctl) commands work without racing the WM."
  ; `P
      "On shutdown $(mname) sends $(b,SIGTERM) to the script process. Children that were \
       backgrounded by the script reparent to PID 1 and survive WM restarts. To kill all \
       script descendants on exit (river-classic behavior), add $(b,trap 'kill 0' EXIT) \
       to the top of the script."
  ; `P "Example $(b,~/.config/ocdwm/init):"
  ; `Pre
      "  #!/usr/bin/env bash\n\
      \  ocdwmctl bind spawn \"kitty\" to Super+Return\n\
      \  ocdwmctl bind window close to Super+q\n\
      \  ocdwmctl set layout floating\n\
      \  pgrep -x waybar >/dev/null || waybar &"
  ; `S Manpage.s_exit_status
  ; `S Manpage.s_see_also
  ]
;;

let cmd =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  Cli.cmd
    ~man
    ~man_xrefs:[ `Tool "ocdwmctl"; `Tool "river" ]
    ~version
    ~name:"ocdwm"
    ~doc:"ocdwm - dwm-like window manager for river 0.4.x, written in OCaml"
  @@
  let+ override_path =
    Arg.(
      value
      & opt (some string) None
      & info
          [ "c" ]
          ~docv:"SHELL_COMMAND"
          ~doc:
            "Override the default search paths for an init executable: instead \
             $(i,SHELL_COMMAND) will be run with /bin/sh -c. See the CONFIGURATION \
             section for more details.")
  and+ log_level = Cli.log_level_arg in
  let init_command = Init_script.resolve ?override_path () in
  run ~init_command ~log_level ()
;;

let main () = Cmdliner.Cmd.eval' cmd
let () = if !Sys.interactive then () else main () |> exit
