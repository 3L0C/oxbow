open! Oxbow_core

let exec argv =
  match argv with
  | [||] | [| "" |] -> Error "nothing to execute"
  | _ ->
    let () =
      match Unix.fork () with
      | 0 ->
        (try Unix.setsid () |> ignore with
         | Unix.Unix_error _ ->
           Printf.eprintf "Exec.exec: setsid failed: %S\n"
           @@ String.concat " " (Array.to_list argv));
        (* Ignored signal dispositions survive execvp. The compositor ignores
           SIGCHLD and SIGPIPE; spawned commands must not inherit that
           (an ignored SIGCHLD breaks waitpid in the child, e.g. wl-copy). *)
        Sys.set_signal Sys.sigchld Sys.Signal_default;
        Sys.set_signal Sys.sigpipe Sys.Signal_default;
        (try Unix.execvp argv.(0) argv with
         | _ ->
           Printf.eprintf "Exec.exec: failed to execute: %S\n"
           @@ String.concat " " (Array.to_list argv));
        Stdlib.exit Exit.unavailable
      | _ -> ()
    in
    Ok None
;;

let spawn cmd = exec [| "/bin/sh"; "-c"; cmd |]
