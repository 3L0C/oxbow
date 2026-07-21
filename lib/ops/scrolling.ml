open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let arrange ctx (output : Output.t) =
  if not @@ Output.has_visible_fullscreen output
  then (
    let windows = Output.tiled_windows output in
    let tag_data = Output.to_tag_data output in
    let area = Gaps.pre tag_data.params output.usable in
    let items =
      List.map
        (fun (w : Window.t) ->
           let width_fac =
             match w.scroll_width with
             | Some wf -> Width_fac.to_float wf
             | None -> tag_data.params.mfact
           in
           w, Strip.Item.{ consumes = w.consumes; width_fac })
        windows
    in
    let bw = Int32.to_int (Ctx.wm ctx).config.borders.width in
    Strip.layout ~usable:area ~offset:0 items
    |> List.iter (fun (w, g) ->
      Gaps.post tag_data.params g
      |> Rect.inset ~by:bw
      |> Window.clamp w
      |> Window.set_geom ctx w;
      let dims = Rect.to_int w.geom in
      let visual = Rect.inset ~by:(-bw) dims in
      match Rect.intersect visual output.usable with
      | None -> w.clip <- None
      | Some i when i = visual -> w.clip <- None
      | Some i -> w.clip <- Some { i with x = i.x - dims.x; y = i.y - dims.y }))
;;
