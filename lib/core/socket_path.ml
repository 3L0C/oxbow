let default () =
  match Sys.getenv_opt "OCDWM_SOCKET" with
  | Some p -> p
  | None ->
    let runtime_dir =
      match Sys.getenv_opt "XDG_RUNTIME_DIR" with
      | Some d -> d
      | None -> Sys.getenv "HOME"
    in
    let display =
      match Sys.getenv_opt "WAYLAND_DISPLAY" with
      | Some d -> d
      | None -> "wayland-0"
    in
    Filename.concat runtime_dir @@ Printf.sprintf "ocdwm-%s.sock" display
;;

let resolve ?override () =
  match override with
  | Some p -> p
  | None -> default ()
;;
