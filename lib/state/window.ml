open! Oxbow_core
include Types.Window

module Lifecycle = struct
  include Types.Window.Lifecycle

  let to_string = function
    | New -> "new"
    | Active -> "active"
    | Closing -> "closing"
  ;;
end

let next_id = Atomic.make 1

let fresh_id () =
  let id = Atomic.get next_id in
  Atomic.incr next_id;
  id
;;

let create (output : Types.Output.t option) scroll_width river_window : t =
  { obj = river_window
  ; node = Emit.get_node river_window
  ; lifecycle = New
  ; id = fresh_id ()
  ; app_id = None
  ; title = None
  ; identifier = None
  ; unreliable_pid = None
  ; parent = None
  ; float_seed_pending = false
  ; close_pending = false
  ; decoration_hint = None
  ; presentation_hint = None
  ; defense = Idle
  ; geom = { x = 0l; y = 0l; w = 0l; h = 0l }
  ; float_geom = None
  ; clip = None
  ; offscreen = false
  ; size_hints = { min_w = 0l; max_w = 0l; min_h = 0l; max_h = 0l }
  ; tags =
      (match output with
       | None -> Tag.Set.singleton 1
       | Some o -> o.tags.selected)
  ; output
  ; output_before_evac = None
  ; sticky = Off
  ; swallow = Auto
  ; labels = []
  ; is_fixed = false
  ; is_urgent = false
  ; is_fake_fullscreen = false
  ; scrolling = { consumes = false; width = scroll_width }
  ; committed =
      { proposed = None
      ; fullscreen_on = None
      ; caps = None
      ; tiled_edges = None
      ; ssd = None
      ; informed_maximized = None
      ; informed_fullscreen = None
      ; informed_resizing = None
      ; borders = None
      }
  ; presentation = Presentation.Tiled
  ; requests = []
  }
;;

let destroy w =
  match w.lifecycle with
  | Closing -> Emit.destroy_window ~window:w.obj ~node:w.node
  | _ ->
    Logs.warn
    @@ fun m ->
    m "destroy refused: Window is %s not closing" (Lifecycle.to_string w.lifecycle)
;;

let set_position w ~x ~y = w.geom <- { w.geom with x; y }
let floor_geom (g : int32 Rect.t) = { g with w = max g.w 0l; h = max g.h 0l }
let set_geom w g = w.geom <- floor_geom g
let set_defense w d = w.defense <- d
let set_proposed w dims = w.committed.proposed <- dims
let set_fullscreen_on w output = w.committed.fullscreen_on <- output
let set_clip w clip = w.clip <- clip

let set_clip_within w ~tag ~bw ~bound =
  let dims = Rect.to_int w.geom in
  let visual = Rect.inset ~by:(-bw) dims in
  match Option.bind bound (Rect.intersect visual) with
  | None -> set_clip w None
  | Some i when i = visual -> set_clip w None
  | Some i -> set_clip w @@ Some (tag, { i with x = i.x - dims.x; y = i.y - dims.y })
;;

let set_offscreen w v = w.offscreen <- v

let reject_dimensions w ~width ~height =
  match w.defense with
  | Bounce (bw, bh) when bw = width && bh = height -> ()
  | Hold (hw, hh) when hw = width && hh = height -> ()
  | Idle | Bounce _ | Hold _ ->
    w.defense <- Bounce (width, height);
    Schedule.manage ()
;;

let tag_layout (o : Types.Output.t) =
  match Tag.Set.first_index o.tags.selected with
  | Some i -> o.tag_data.(i - 1)
  | None -> invalid_arg "Got an output with no selected tags."
;;

let on_tags w ~tags = Tag.Set.intersects tags w.tags

let occupied_tags ?except windows =
  List.fold_left
    (fun s w ->
       match except with
       | Some w' when w' == w -> s
       | Some _ | None -> Tag.Set.union s w.tags)
    Tag.Set.empty
    windows
;;

let tag_visible w =
  match w.output, w.swallow with
  | None, _ | _, Swallowed_by _ -> false
  | Some o, _ ->
    if o.overview.enabled
    then true
    else (
      match w.sticky with
      | Off -> on_tags ~tags:o.tags.selected w
      | All -> true
      | Occupied ->
        occupied_tags ~except:w o.wm_stack |> Tag.Set.intersects o.tags.selected)
;;

let is_tiled w = w.presentation = Tiled
let is_tiled_on_tag w = tag_visible w && is_tiled w

let swallowing w =
  match w.swallow with
  | Swallowing _ -> true
  | Auto | Terminal | Disabled | Swallowed_by _ -> false
;;

let can_swallow w =
  match w.swallow with
  | Terminal -> true
  | Auto | Disabled | Swallowing _ | Swallowed_by _ -> false
;;

let remember_float w = w.float_geom <- Some w.geom

let tile w =
  if w.presentation = Floating then remember_float w;
  w.presentation <- Tiled
;;

let clamp_dim ~min_v ~max_v v =
  v
  |> (if min_v > 0l then Int32.max min_v else Fun.id)
  |> if max_v > 0l then Int32.min max_v else Fun.id
;;

let clamp w (g : int Rect.t) =
  let h = w.size_hints in
  Rect.(
    Int32.
      { x = of_int g.x
      ; y = of_int g.y
      ; w = of_int g.w |> clamp_dim ~min_v:h.min_w ~max_v:h.max_w
      ; h = of_int g.h |> clamp_dim ~min_v:h.min_h ~max_v:h.max_h
      })
;;

let clamp32 w (g : int32 Rect.t) =
  let h = w.size_hints in
  Rect.
    { x = g.x
    ; y = g.y
    ; w = clamp_dim ~min_v:h.min_w ~max_v:h.max_w g.w
    ; h = clamp_dim ~min_v:h.min_h ~max_v:h.max_h g.h
    }
;;

let set_float_seed_pending w v = w.float_seed_pending <- v

let restore_or_seed_float w =
  set_float_seed_pending w false;
  match w.output with
  | None -> ()
  | Some o ->
    let g =
      match w.float_geom with
      | Some g -> g
      | None ->
        let usable =
          Rect.(
            Int32.
              { x = of_int o.usable.x
              ; y = of_int o.usable.y
              ; w = of_int o.usable.w
              ; h = of_int o.usable.h
              })
        in
        let sized = clamp32 w { w.geom with x = 0l; y = 0l } in
        let spare_w = Int32.(sub usable.w sized.w |> max 0l) in
        let spare_h = Int32.(sub usable.h sized.h |> max 0l) in
        Rect.(
          Int32.
            { x = div spare_w 2l |> add usable.x
            ; y = div spare_h 2l |> add usable.y
            ; w = sized.w
            ; h = sized.h
            })
    in
    w.float_geom <- Some g;
    set_geom w g
;;

let float w =
  w.presentation <- Floating;
  w.defense <- Idle;
  restore_or_seed_float w
;;

let is_fullscreen w =
  match w.presentation with
  | Fullscreen _ -> true
  | _ -> false
;;

let fullscreen ?(force : bool = false) w =
  match w.output with
  | None -> ()
  | Some o ->
    let enter restore =
      w.presentation <- Fullscreen { restore };
      set_geom w o.geom
    in
    (match w.presentation with
     | Tiled -> enter `Tiled
     | Floating -> enter `Floating
     | Maximized { restore } -> enter (`Maximized restore)
     | Fullscreen { restore } when force -> enter restore
     | Fullscreen _ -> ())
;;

let maximize ?restore w =
  let enter restore =
    match w.output with
    | None -> ()
    | Some o ->
      let g =
        Rect.(
          Int32.
            { x = of_int o.usable.x
            ; y = of_int o.usable.y
            ; w = of_int o.usable.w
            ; h = of_int o.usable.h
            })
      in
      w.presentation <- Maximized { restore };
      set_geom w g
  in
  match restore with
  | None ->
    (match w.presentation with
     | Tiled -> enter `Tiled
     | Floating ->
       remember_float w;
       enter `Floating
     | Fullscreen _ | Maximized _ -> ())
  | Some r -> enter r
;;

let unmaximize w =
  match w.presentation with
  | Tiled | Floating | Fullscreen _ -> ()
  | Maximized { restore } ->
    (match restore with
     | `Tiled -> tile w
     | `Floating -> float w)
;;

let exit_fullscreen w =
  match w.output, w.presentation with
  | Some _, Fullscreen { restore } ->
    set_proposed w None;
    w
    |>
      (match restore with
      | `Tiled -> tile
      | `Floating -> float
      | `Maximized restore -> maximize ~restore)
  | _, (Tiled | Floating | Maximized _ | Fullscreen _) -> ()
;;

let is_rendered w =
  tag_visible w
  && (match w.output with
      | None -> false
      | Some o ->
        (not (o.overview.enabled && w.offscreen))
        && (not
            @@ List.exists
                 (fun w' -> w' != w && is_fullscreen w' && tag_visible w')
                 o.focus_stack))
  &&
  match w.output with
  | Some o when (tag_layout o).layout = Scrolling && is_tiled w ->
    Rect.(intersect (to_int w.geom) o.usable) |> Option.is_some
  | _ -> true
;;

let queue_request w request =
  w.requests <- request :: w.requests;
  Schedule.manage ()
;;

let clear_requests w = w.requests <- []

let fit_to_output w =
  match w.output with
  | None -> ()
  | Some o ->
    let new_x =
      if w.geom.w > o.geom.w
      then o.geom.x
      else (
        let max_x = Int32.(sub o.geom.w w.geom.w |> add o.geom.x) in
        Int32.(w.geom.x |> max o.geom.x |> min max_x))
    in
    let new_y =
      if w.geom.h > o.geom.h
      then o.geom.y
      else (
        let max_y = Int32.(sub o.geom.h w.geom.h |> add o.geom.y) in
        Int32.(w.geom.y |> max o.geom.y |> min max_y))
    in
    if new_x <> w.geom.x || new_y <> w.geom.y then set_position w ~x:new_x ~y:new_y
;;

let at_point ~x ~y = List.find_opt (fun w -> tag_visible w && Rect.contains ~x ~y w.geom)
let fake_fullscreen w = if not w.is_fake_fullscreen then w.is_fake_fullscreen <- true
let exit_fake_fullscreen w = if w.is_fake_fullscreen then w.is_fake_fullscreen <- false

let float_in_place w =
  match w.presentation with
  | Floating -> ()
  | Fullscreen _ -> Logs.err @@ fun m -> m "unable to float fullscreen window"
  | Tiled | Maximized _ ->
    remember_float w;
    w.presentation <- Floating
;;

let apply_float_geom w g =
  clamp w g |> set_geom w;
  remember_float w
;;

let with_float_edit w f =
  if is_fullscreen w
  then Logs.err @@ fun m -> m "unable to move fullscreen window"
  else (
    match w.output with
    | None -> ()
    | Some o ->
      float_in_place w;
      f o |> apply_float_geom w)
;;

let move_to w ~x ~y =
  with_float_edit w
  @@ fun o ->
  let cur = Rect.to_int w.geom in
  { cur with
    x = o.usable.x + Extent.resolve x ~ref:o.usable.w
  ; y = o.usable.y + Extent.resolve y ~ref:o.usable.h
  }
;;

let move_spatial w (dir : Direction.Spatial.t) by =
  with_float_edit w
  @@ fun o ->
  let cur = Rect.to_int w.geom in
  let dx = Extent.resolve by ~ref:o.usable.w in
  let dy = Extent.resolve by ~ref:o.usable.h in
  match dir with
  | Up -> { cur with y = cur.y - dy }
  | Down -> { cur with y = cur.y + dy }
  | Left -> { cur with x = cur.x - dx }
  | Right -> { cur with x = cur.x + dx }
;;

let resize_to w ~width ~height =
  with_float_edit w
  @@ fun o ->
  let cur = Rect.to_int w.geom in
  { cur with
    w = Extent.resolve width ~ref:o.usable.w
  ; h = Extent.resolve height ~ref:o.usable.h
  }
;;

let resize_spatial w (dir : Direction.Spatial.t) by =
  with_float_edit w
  @@ fun o ->
  let cur = Rect.to_int w.geom in
  let dx = Extent.resolve by ~ref:o.usable.w in
  let dy = Extent.resolve by ~ref:o.usable.h in
  match dir with
  | Up -> { cur with y = cur.y - dy; h = cur.h + dy }
  | Down -> { cur with h = cur.h + dy }
  | Left -> { cur with x = cur.x - dx; w = cur.w + dx }
  | Right -> { cur with w = cur.w + dx }
;;

let set_tags w tags =
  if not @@ Tag.Set.is_empty tags
  then (
    w.tags <- tags;
    Schedule.manage ())
  else invalid_arg "Windows cannot have an empty set of tags."
;;

let set_consumes w v =
  if v <> w.scrolling.consumes
  then (
    w.scrolling.consumes <- v;
    Schedule.manage ())
;;

let set_scroll_width w v =
  if w.scrolling.width <> v
  then (
    w.scrolling.width <- v;
    Schedule.manage ())
;;

let set_output w output =
  let aux () =
    Schedule.manage ();
    w.output <- output;
    set_fullscreen_on w None;
    set_proposed w None
  in
  match w.output, output with
  | Some o, None when Option.is_none w.output_before_evac ->
    w.output_before_evac <- o.name;
    aux ()
  | _ -> aux ()
;;

let set_presentation w presentation =
  w.presentation <- presentation;
  Schedule.manage ()
;;

let set_is_urgent w is_urgent =
  w.is_urgent <- is_urgent;
  Schedule.manage ()
;;

let set_lifecycle w lifecycle = w.lifecycle <- lifecycle
let set_title w title = w.title <- title
let set_app_id w app_id = w.app_id <- app_id
let set_identifier w identifier = w.identifier <- identifier
let set_unreliable_pid w pid = w.unreliable_pid <- pid

let set_parent w ~parent =
  w.parent <- parent;
  Schedule.manage ()
;;

let set_close_pending w v = w.close_pending <- v
let set_decoration_hint w hint = w.decoration_hint <- hint
let set_presentation_hint w hint = w.presentation_hint <- hint
let set_size_hints w hints = w.size_hints <- hints

let set_sticky w scope =
  if w.sticky <> scope
  then (
    w.sticky <- scope;
    Schedule.manage ())
;;

let add_label w label =
  if not @@ List.mem label w.labels
  then w.labels <- label :: w.labels |> List.sort String.compare
;;

let remove_label w label = w.labels <- List.filter (( <> ) label) w.labels

let set_swallow w v =
  w.swallow <- v;
  Schedule.manage ()
;;

let set_swallow_role w v =
  match w.swallow with
  | Swallowing _ | Swallowed_by _ -> ()
  | Auto | Terminal | Disabled -> set_swallow w v
;;

let swallow ~host ~child =
  set_swallow child (Swallowing host);
  set_swallow host (Swallowed_by child)
;;

let set_is_fixed w is_fixed = w.is_fixed <- is_fixed

let rehome w name =
  match w.output_before_evac with
  | Some n when String.equal n name ->
    w.output_before_evac <- None;
    queue_request w @@ Send_to_output_name { name; policy = Tag.Policy.Keep }
  | _ -> ()
;;

let presentation_string w =
  match w.presentation with
  | Tiled -> "tiled"
  | Floating -> "floating"
  | Maximized _ -> "maximized"
  | Fullscreen _ -> "fullscreen"
;;

let set_informed_fullscreen w o = w.committed.informed_fullscreen <- o
let set_informed_maximized w o = w.committed.informed_maximized <- o
let set_informed_resizing w o = w.committed.informed_resizing <- o
let set_caps w o = w.committed.caps <- o
let set_tiled_edges w o = w.committed.tiled_edges <- o
let set_ssd w o = w.committed.ssd <- o
let set_borders w o = w.committed.borders <- o
