open! Ocdwm_core
open! Ocdwm_layout
open! Ocdwm_state

let set_mfact (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_mfact o delta;
    Ok None
;;

let set_nmaster (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_nmaster o delta;
    Ok None
;;

let set_gaps_inner (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_gaps_inner o delta;
    Ok None
;;

let set_gaps_outer (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_gaps_outer o delta;
    Ok None
;;

let set_stack (seat : Seat.t) kind =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_stack o kind;
    Ok None
;;

let set_dir (seat : Seat.t) dir =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_dir o dir;
    Ok None
;;

let retile ctx output =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    let count = List.length windows in
    let tag_data = Output.to_tag_data output in
    let area = Gaps.pre tag_data.params output.usable in
    let dir = tag_data.params.dir in
    let compute = Entry.compute tag_data.entry in
    let dimensions =
      compute ~params:tag_data.params ~usable_area:(Xform.pre dir area) ~count
      |> List.map (Xform.post dir ~area)
      |> List.map (Gaps.post tag_data.params)
    in
    match windows, dimensions with
    | _, [] when count <> 0 ->
      List.iter (fun w -> Window.restore_or_seed_float ctx w) windows
    | _, d_xs when List.length d_xs <> count ->
      let layout_name = Entry.name tag_data.entry in
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
