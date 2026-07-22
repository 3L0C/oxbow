open! Ocdwm_core
open! Ocdwm_layout
open! Ocdwm_state

let arrange ctx output =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    let count = List.length windows in
    let tag_data = Output.to_tag_data output in
    let area = Gaps.pre tag_data.params output.usable in
    let dir = tag_data.params.dir in
    let compute = Schemes.compute tag_data.scheme in
    let dimensions =
      compute ~params:tag_data.params ~usable_area:(Xform.pre dir area) ~count
      |> List.map (Xform.post dir ~area)
      |> List.map (Gaps.post tag_data.params)
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
        (fun w g -> Rect.inset ~by:bw g |> Window.clamp w |> Window.set_geom ctx w)
        w_xs
        d_xs)
;;
