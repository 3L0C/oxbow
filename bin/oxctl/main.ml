open! Cmdliner
open! Oxbow_ctl

let version =
  match Build_info.V1.version () with
  | Some v -> Build_info.V1.Version.to_string v
  | None -> "dev"
;;

let setup () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.(set_level (Some Info))
;;

let main () =
  let argv =
    match Array.to_list Sys.argv with
    | [] | [ _ ] -> Sys.argv
    | x :: xs -> x :: Ctl_cli.preparse_args xs |> Array.of_list
  in
  setup ();
  Cmd.eval' ~argv @@ Cmd_oxctl.cmd ~version
;;

let () = if !Sys.interactive then () else exit (main ())
