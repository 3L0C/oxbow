open! Ocdwm_state

let apply ctx window =
  let tiled = Window.is_tiled window in
  let edges =
    let open River.Window_management.River_window_v1 in
    if tiled
    then Int32.(logor Edges.left Edges.right |> logor Edges.top |> logor Edges.bottom)
    else Edges.none
  in
  Send.set_tiled ctx window ~edges;
  match window.decoration_hint with
  | Some Only_csd -> ()
  | _ when tiled -> Send.use_ssd ctx window
  | Some Prefer_csd -> Send.use_csd ctx window
  | Some Prefer_ssd | Some No_preference | None -> Send.use_ssd ctx window
;;
