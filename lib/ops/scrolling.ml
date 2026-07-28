open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let arrange ctx (output : Output.t) =
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
    let bw = Int32.to_int (Ctx.wm ctx).config.borders.width in
    let placed = Strip.layout ~usable:area ~offset:0 items in
    match placed with
    | [] -> ()
    | _ ->
      let _, last = List.rev placed |> List.hd in
      let total_w = last.x + last.w - area.x in
      let col =
        match Output.focused_window output with
        | Some f when (not @@ Window.is_fullscreen f) && Window.is_tiled f ->
          let hit = List.find_opt (fun (w, _) -> w == f) placed in
          (match hit with
           | None -> None
           | Some (_, g) -> Some (g.x - area.x, g.w))
        | _ -> None
      in
      let offset =
        match col with
        | Some col ->
          Strip.scroll
            ~policy:tag_data.scrolling.policy
            ~viewport_w:area.w
            ~total_w
            ~offset:output.scroll_offset
            ~col
        | None ->
          (match tag_data.scrolling.policy with
           | Centered -> output.scroll_offset
           | Left | Visible -> min output.scroll_offset (total_w - area.w) |> max 0)
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
        | None -> w.clip <- None
        | Some i when i = visual -> w.clip <- None
        | Some i -> w.clip <- Some { i with x = i.x - dims.x; y = i.y - dims.y }))
;;
