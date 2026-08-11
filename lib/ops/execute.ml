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
