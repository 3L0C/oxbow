open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let row ~start ~y ~h widths =
  List.fold_left_map (fun x cw -> x + cw, Rect.{ x; y; w = cw; h }) start widths |> snd
;;

let arrange ctx (output : Output.t) =
  let windows = output.wm_stack in
  let n = List.length windows in
  if n = 0
  then ()
  else (
    let usable = output.usable in
    let bw = (Ctx.wm ctx).config.borders.width |> Int32.to_int in
    let params = (Output.to_tag_data output).params in
    let cols = float n |> sqrt |> ceil |> int_of_float in
    let rows = (n + cols - 1) / cols in
    let row_heights = Tile.split ~total:usable.h ~count:rows in
    let dimensions =
      List.fold_left_map
        (fun (y, rem) rh ->
           let cells = min cols rem in
           let widths = Tile.split ~total:usable.w ~count:cells in
           (y + rh, rem - cells), row ~start:usable.x ~y ~h:rh widths)
        (usable.y, n)
        row_heights
      |> snd
      |> List.concat
    in
    List.iter2
      (fun window rect ->
         Gaps.post params rect
         |> Rect.inset ~by:bw
         |> Window.clamp window
         |> Window.set_geom ctx window)
      windows
      dimensions)
;;
