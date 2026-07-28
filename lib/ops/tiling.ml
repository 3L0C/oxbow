open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let arrange ctx output =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    let count = List.length windows in
    let tag_data = Output.to_tag_data output in
    let area = Gaps.pre tag_data.gaps output.usable in
    let dir = tag_data.tiling.dir in
    let dimensions =
      Schemes.compute ~params:tag_data.tiling ~usable_area:(Xform.pre dir area) ~count
      |> List.map (Xform.post dir ~area)
      |> List.map (Gaps.post tag_data.gaps)
    in
    match windows, dimensions with
    | _, d_xs when List.length d_xs <> count ->
      let layout_name = Layout.to_string tag_data.layout in
      Logs.warn
      @@ fun m ->
      m
        "retile skipped: layout %S returned unexpected geometry count. Expected %d, got \
         %d"
        layout_name
        count
        (List.length d_xs)
    | w_xs, d_xs ->
      let bw = Int32.to_int (Ctx.wm ctx).config.borders.width in
      List.iter2
        (fun w g -> Rect.inset ~by:bw g |> Window.clamp w |> Window.set_geom w)
        w_xs
        d_xs)
;;

let zoom ?warp ctx seat =
  With.focused_window seat
  @@ fun o w ->
  if Output.current_layout o <> Tiling
  then Error "cannot zoom outside the tiling layout"
  else if w.presentation <> Tiled
  then Error "focused window is not tiled"
  else (
    let warp = Seat.Warp_request.of_override warp in
    match Output.tiled_windows o with
    | w' :: x :: _ when w' == w ->
      Stacking.push [ x; w ] o;
      Focus.focus_window ~force:true ~warp ctx seat x;
      Ok None
    | w' :: _ when w' != w ->
      Stacking.push [ w; w' ] o;
      Focus.focus_window ~force:true ~warp ctx seat w;
      Ok None
    | _ -> Error "no window to zoom with")
;;
