open! Oxbow_core
open! Oxbow_state
open! Oxbow_layout

let arrange (wm : Wm.t) (output : Output.t) =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    let td = Output.to_tag_data output in
    let area = Gaps.pre td.gaps output.usable in
    let dir = td.scrolling.dir in
    let c_area = Xform.pre dir area in
    let items =
      List.map
        (fun (w : Window.t) ->
           let width_fac = Width_fac.to_float w.scrolling.width in
           w, Strip.Item.{ consumes = w.scrolling.consumes; width_fac })
        windows
    in
    let bw = Int32.to_int wm.config.borders.width in
    let placed = Strip.layout ~usable:c_area ~offset:0 items in
    match placed with
    | [] -> Output.set_scroll_offset output 0
    | _ ->
      let _, last = List.rev placed |> List.hd in
      let max_offset = last.x - c_area.x in
      let nearest_col () =
        let view_center = td.scrolling.offset + (c_area.w / 2) in
        List.fold_left
          (fun best (_, (g : int Rect.canonical)) ->
             let x = g.x - c_area.x in
             let d = abs (x + (g.w / 2) - view_center) in
             match best with
             | Some (d', _) when d' <= d -> best
             | _ -> Some (d, (x, g.w)))
          None
          placed
        |> Option.map snd
      in
      let col =
        match Output.focused_window output with
        | Some f when Window.is_tiled f && (not @@ Window.is_fullscreen f) ->
          (match List.find_opt (fun (w, _) -> w == f) placed with
           | Some (_, g) -> Some (g.x - c_area.x, g.w)
           | None -> nearest_col ())
        | _ -> None
      in
      let offset =
        match col with
        | Some col ->
          Strip.scroll
            ~align:td.scrolling.align
            ~viewport_w:c_area.w
            ~max_offset
            ~offset:td.scrolling.offset
            ~col
        | None -> min td.scrolling.offset max_offset |> max 0
      in
      Output.set_scroll_offset output offset;
      placed
      |> List.map (fun (w, g) -> w, Rect.{ g with x = g.x - offset })
      |> List.map (fun (w, g) -> w, Xform.post dir ~area g)
      |> List.iter (fun (w, g) ->
        Gaps.post td.gaps g |> Rect.inset ~by:bw |> Window.clamp w |> Window.set_geom w;
        Window.set_clip_within w ~tag:`Scrolling ~bw ~bound:(Some output.usable)))
;;
