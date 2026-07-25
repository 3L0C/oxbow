open! Ocdwm_state

let apply (_ctx : Ctx.manage Ctx.t) window =
  let tiled = Window.is_tiled window in
  let edges =
    if tiled
    then
      let open River.Window_management.River_window_v1.Edges in
      Int32.(logor left right |> logor top |> logor bottom)
    else River.Window_management.River_window_v1.Edges.none
  in
  River.Window_management.River_window_v1.set_tiled window.obj ~edges;
  match window.decoration_hint with
  | Some Only_csd -> ()
  | _ when tiled -> River.Window_management.River_window_v1.use_ssd window.obj
  | Some Prefer_csd -> River.Window_management.River_window_v1.use_csd window.obj
  | Some Prefer_ssd | Some No_preference | None ->
    River.Window_management.River_window_v1.use_ssd window.obj
;;
