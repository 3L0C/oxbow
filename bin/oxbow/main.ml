module Cli = Oxbow_core.Cli
module Exceptions = Oxbow_runtime.Exceptions
module Exit = Oxbow_core.Exit
module Init_script = Oxbow_state.Init_script
module Run = Oxbow_runtime.Run

let version =
  match Build_info.V1.version () with
  | Some v -> Build_info.V1.Version.to_string v
  | None -> "dev"
;;

let setup ~log_level =
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter @@ Logs_fmt.reporter ();
  Logs.(set_level (Some log_level));
  Sys.set_signal Sys.sigchld Sys.Signal_ignore;
  Printexc.record_backtrace true
;;

let run ~init_command ~log_level ?socket_path () =
  setup ~log_level;
  try
    Eio_main.run
    @@ fun env -> Run.loop ?socket_path ~init_command ~net:env#net ~clock:env#clock ()
  with
  | Failure s ->
    Printf.eprintf "%s\n" s;
    Exit.software
  | Exceptions.Unavailable -> Exit.unavailable
;;

let man =
  let open Cmdliner in
  [ `S Manpage.s_synopsis
  ; `S Manpage.s_options
  ; `S Manpage.s_common_options
  ; `S "CONFIGURATION"
  ; `P
      "On startup $(mname) runs an init script that issues $(b,oxctl)(1) commands to set \
       keybindings, layouts, and window rules. The script is located by checking, in \
       order:"
  ; `I
      ( "1."
      , "The $(b,-c) $(i,SHELL_COMMAND) argument. If given, $(i,SHELL_COMMAND) is run \
         literally via $(b,/bin/sh -c) with no path search;" )
  ; `Noblank
  ; `I ("2.", "$(b,\\$XDG_CONFIG_HOME/oxbow/init), if executable;")
  ; `Noblank
  ; `I ("3.", "$(b,\\$HOME/.config/oxbow/init), if executable;")
  ; `P "If none are found or executable, $(mname) starts with only built-in keybindings."
  ; `P
      "The script runs in its own session via $(b,setsid)(2), after the river protocols \
       are bound, so $(b,oxctl) commands work without racing $(mname)."
  ; `P
      "On shutdown $(mname) sends $(b,SIGTERM) to the script process. Children that were \
       backgrounded by the script reparent to PID 1 and survive WM restarts. To kill all \
       script descendants on exit, add $(b,trap 'kill 0' EXIT) to the top of the script."
  ; `P "Example $(b,~/.config/oxbow/init):"
  ; `Pre
      "  #!/usr/bin/env bash\n\
      \  oxctl bind spawn \"kitty\" to Super+Return\n\
      \  oxctl bind window close to Super+q\n\
      \  oxctl layout floating\n\
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
    ~man_xrefs:[ `Tool "oxctl"; `Tool "river" ]
    ~version
    ~name:"oxbow"
    ~doc:"A dynamic window manager for river 0.4.6+, written in OCaml"
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
             $(i,SHELL_COMMAND) will be run with /bin/sh -c. See the $(b,CONFIGURATION) \
             section for more details.")
  and+ log_level = Cli.log_level_arg
  and+ socket_path = Cli.socket_arg in
  let init_command = Init_script.resolve ?override_path () in
  run ~init_command ~log_level ?socket_path ()
;;

let main () = Cmdliner.Cmd.eval' cmd
let () = if !Sys.interactive then () else main () |> exit
