open! Ocdwm_core

let spawn cmd =
  let command = [| "/bin/sh"; "-c"; cmd |] in
  match Unix.fork () with
  | 0 ->
    (try Unix.setsid () |> ignore with
     | Unix.Unix_error _ ->
       Printf.eprintf "Spawn.cmd: setsid failed while trying to spawn %S\n" cmd);
    (try Unix.execv command.(0) command with
     | _ -> Printf.eprintf "Spawn.cmd: failed to spawn %S\n" cmd);
    Stdlib.exit Exit.unavailable
  | _ -> ()
;;
