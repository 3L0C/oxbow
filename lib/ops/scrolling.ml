open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let arrange (wm : Wm.t) (output : Output.t) =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    let tag_data = Output.to_tag_data output in
    let area = Gaps.pre tag_data.gaps output.usable in
    let items =
      List.map
        (fun (w : Window.t) ->
           let width_fac = Width_fac.to_float w.scrolling.width in
           w, Strip.Item.{ consumes = w.scrolling.consumes; width_fac })
        windows
    in
    let bw = Int32.to_int wm.config.borders.width in
    let placed = Strip.layout ~usable:area ~offset:0 items in
    match placed with
    | [] -> Output.set_scroll_offset output 0
    | _ ->
      let _, last = List.rev placed |> List.hd in
      let max_offset = last.x - area.x in
      let nearest_col () =
        let view_center = output.scroll.offset + (area.w / 2) in
        List.fold_left
          (fun best (_, (g : int Rect.t)) ->
             let x = g.x - area.x in
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
           | Some (_, g) -> Some (g.x - area.x, g.w)
           | None -> nearest_col ())
        | _ -> nearest_col ()
      in
      let offset =
        match col with
        | Some col ->
          Strip.scroll
            ~policy:tag_data.scrolling.policy
            ~viewport_w:area.w
            ~max_offset
            ~offset:output.scroll.offset
            ~col
        | None -> min output.scroll.offset max_offset |> max 0
      in
      Output.set_scroll_offset output offset;
      placed
      |> List.map (fun (w, g) -> w, Rect.{ g with x = g.x - offset })
      |> List.iter (fun (w, g) ->
        Gaps.post tag_data.gaps g
        |> Rect.inset ~by:bw
        |> Window.clamp w
        |> Window.set_geom w;
        let dims = Rect.to_int w.geom in
        let visual = Rect.inset ~by:(-bw) dims in
        match Rect.intersect visual output.usable with
        | None -> Window.set_clip w None
        | Some i when i = visual -> Window.set_clip w None
        | Some i ->
          Window.set_clip w
          @@ Some (`Scrolling, { i with x = i.x - dims.x; y = i.y - dims.y })))
;;
