open! Cmdliner
open! Oxbow_ctl

let version =
  match Build_info.V1.version () with
  | Some v -> Build_info.V1.Version.to_string v
  | None -> "dev"
;;

let setup () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.(set_level (Some Info))
;;

let main () =
  setup ();
  Cmd.eval' @@ Cmd_oxctl.cmd ~version
;;

let () = if !Sys.interactive then () else exit (main ())
