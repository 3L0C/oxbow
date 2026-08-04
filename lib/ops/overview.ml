open! Oxbow_core
open! Oxbow_state
open! Oxbow_layout

let arrange (wm : Wm.t) (output : Output.t) =
  let windows = output.focus_stack in
  let n = List.length windows in
  if n = 0
  then ()
  else (
    let bw = wm.config.borders.width |> Int32.to_int in
    let gaps =
      Params.Gaps.{ inner = output.overview.gaps; outer = output.overview.gaps }
    in
    let usable = Gaps.pre gaps output.usable in
    let cols = min 3 n in
    let row_h = usable.h / 2 in
    let widths = Strip.split ~total:usable.w ~count:cols |> Array.of_list in
    let xs =
      Array.fold_left (fun (acc, x) w -> x :: acc, x + w) ([], usable.x) widths
      |> fst
      |> List.rev
      |> Array.of_list
    in
    let max_offset = (n - 1) / cols * row_h in
    let offset =
      match Output.focused_window output with
      | Some f ->
        (match List.find_index (( == ) f) windows with
         | Some i ->
           let row = i / cols in
           Strip.scroll
             ~policy:Scroll_policy.Visible
             ~viewport_w:usable.h
             ~max_offset
             ~offset:output.overview.offset
             ~col:(row * row_h, row_h)
         | None -> min output.overview.offset max_offset |> max 0)
      | None -> min output.overview.offset max_offset |> max 0
    in
    output.overview.offset <- offset;
    List.iteri
      (fun i window ->
         let col = i mod cols in
         let row = i / cols in
         let rect =
           Rect.
             { x = xs.(col)
             ; y = usable.y + (row * row_h) - offset
             ; w = widths.(col)
             ; h = row_h
             }
         in
         let cell = Gaps.post gaps rect in
         Rect.inset ~by:bw cell |> Window.clamp window |> Window.set_geom window;
         let bound = Rect.intersect cell output.usable in
         Option.is_none bound |> Window.set_offscreen window;
         Window.set_clip_within window ~tag:`Overview ~bw ~bound)
      windows)
;;
