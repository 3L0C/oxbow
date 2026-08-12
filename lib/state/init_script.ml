open! Oxbow_core

type t = { pid : int }

let init_path path =
  try
    Unix.access path [ Unix.X_OK ];
    Some path
  with
  | Unix.Unix_error (e, _, _) ->
    (Log.err @@ fun m -> m "invalid init path %S: %s" path (Unix.error_message e));
    None
;;

let resolve ?override_path () =
  match override_path with
  | Some path -> init_path path
  | None ->
    let config_dir =
      match Sys.getenv_opt "XDG_CONFIG_HOME" with
      | Some d -> Some (d ^ "/oxbow/init")
      | None ->
        (match Sys.getenv_opt "HOME" with
         | Some d -> Some (d ^ "/.config/oxbow/init")
         | None -> None)
    in
    (match config_dir with
     | None ->
       (Log.err
        @@ fun m ->
        m "unable to locate $XDG_CONFIG_HOME or $HOME. Please check your environment");
       None
     | Some path -> init_path path)
;;

let fork ~cmd =
  let argv = [| "/bin/sh"; "-c"; cmd |] in
  match Unix.fork () with
  | 0 ->
    (try Unix.setsid () |> ignore with
     | Unix.Unix_error _ ->
       Printf.eprintf "oxbow: [ERROR] Failed setsid during init script fork: %S\n" cmd);
    (try Unix.execv argv.(0) argv with
     | _ -> Printf.eprintf "oxbow: [ERROR] Failed to exec init script: %S\n" cmd);
    Stdlib.exit Exit.unavailable
  | pid -> { pid }
;;

let shutdown { pid } =
  try Unix.kill pid Sys.sigterm with
  | Unix.Unix_error (Unix.ESRCH, _, _) -> ()
  | Unix.Unix_error (e, _, _) ->
    Log.warn
    @@ fun m -> m "init_script.shutdown: kill -%d failed: %s" pid (Unix.error_message e)
;;
