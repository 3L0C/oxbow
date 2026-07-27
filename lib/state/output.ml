open! Ocdwm_core
include Types.Output

let focused_window (o : t) = List.find_opt Window.tag_visible o.focus_stack

let next_tiled : Types.Window.t list -> Types.Window.t option =
  Ring.wrapped_search Window.tag_visible (fun w -> (Option.get w.output).wm_stack)
;;

let prev_tiled : Types.Window.t list -> Types.Window.t option =
  Ring.wrapped_search Window.tag_visible (fun w ->
    (Option.get w.output).wm_stack |> List.rev)
;;

let next_window (o : t) =
  match focused_window o with
  | None -> None
  | Some f ->
    let rec after = function
      | [ w ] when w == f -> next_tiled o.wm_stack
      | w :: xs when w == f -> next_tiled xs
      | _ :: xs -> after xs
      | [] ->
        (Logs.err @@ fun m -> m "Focused window isn't in output window list");
        None
    in
    after o.wm_stack
;;

let prev_window (o : t) =
  match focused_window o with
  | None -> None
  | Some f ->
    let rec after = function
      | [ w ] when w == f -> List.rev o.wm_stack |> prev_tiled
      | w :: xs when w == f -> prev_tiled xs
      | _ :: xs -> after xs
      | [] ->
        (Logs.err @@ fun m -> m "Focused window isn't in output window list");
        None
    in
    List.rev o.wm_stack |> after
;;

let tag_data (o : t) tag =
  match Tag.Set.first tag with
  | Some i -> o.tag_data.(i - 1)
  | None -> invalid_arg "no tag data for the empty set"
;;

let to_tag_data (o : t) =
  match Tag.Set.first o.selected_tags with
  | Some i -> o.tag_data.(i - 1)
  | None -> invalid_arg "Got an output with no selected tags."
;;

let windows_on_tags (o : t) ~tags = List.filter (Window.on_tags ~tags) o.wm_stack
let visible_windows (o : t) = List.filter Window.tag_visible o.wm_stack
let visible_window_count (o : t) = visible_windows o |> List.length
let tiled_windows (o : t) = List.filter Window.is_tiled_on_tag o.wm_stack

let switch_tags ~tags (o : t) =
  if not (Tag.Set.is_empty tags || Tag.Set.equal tags o.selected_tags)
  then (
    o.previous_tags <- o.selected_tags;
    o.selected_tags <- tags;
    Schedule.manage ())
;;

let occupied_tags (o : t) =
  List.fold_left
    (fun s (w : Types.Window.t) -> Tag.Set.union s w.tags)
    Tag.Set.empty
    o.wm_stack
;;

let urgent_tags (o : t) =
  List.fold_left
    (fun s (w : Types.Window.t) -> if w.is_urgent then Tag.Set.union s w.tags else s)
    Tag.Set.empty
    o.wm_stack
;;

let current_layout o = (to_tag_data o).layout
let current_scheme o = (to_tag_data o).tiling.scheme
let at_point ~x ~y = List.find_opt (fun (o : t) -> Rect.contains ~x ~y o.geom)

let has_visible_fullscreen (o : Types.Output.t) =
  List.exists (fun w -> Window.is_fullscreen w && Window.tag_visible w) o.focus_stack
;;

let is_floating output =
  match output with
  | None -> false
  | Some o -> current_layout o = Floating
;;

let set_layout o layout ~global =
  let apply (td : Types.Config.Data.t) = td.layout <- layout in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_scheme o scheme ~global =
  let apply (td : Types.Config.Data.t) = td.tiling.scheme <- scheme in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let cycle_scheme o dir ~global =
  let apply (td : Types.Config.Data.t) =
    td.tiling.scheme <- Scheme.cycle td.tiling.scheme dir
  in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_overview (o : t) v =
  o.overview <- v;
  Schedule.manage ()
;;

let set_mfact o (delta : float Delta.t) ~global =
  let apply (td : Types.Config.Data.t) =
    let params = td.tiling in
    let mfact =
      match delta with
      | Delta.Abs a -> a
      | Delta.Rel r -> params.mfact +. r
    in
    params.mfact <- Float.(max 0.05 mfact |> min 0.95)
  in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_nmaster o (delta : int Delta.t) ~global =
  let apply (td : Types.Config.Data.t) =
    let params = td.tiling in
    let nmaster =
      match delta with
      | Delta.Abs a -> a
      | Delta.Rel r -> params.nmaster + r
    in
    params.nmaster <- max 0 nmaster
  in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_gaps_inner o (delta : int Delta.t) ~global =
  let apply (td : Types.Config.Data.t) =
    let params = td.gaps in
    let gaps_inner =
      match delta with
      | Delta.Abs a -> a
      | Delta.Rel r -> params.inner + r
    in
    params.inner <- max 0 gaps_inner
  in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_gaps_outer o (delta : int Delta.t) ~global =
  let apply (td : Types.Config.Data.t) =
    let params = td.gaps in
    let outer =
      match delta with
      | Delta.Abs a -> a
      | Delta.Rel r -> params.outer + r
    in
    params.outer <- max 0 outer
  in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_scroll_policy o policy ~global =
  let apply (td : Types.Config.Data.t) = td.scrolling.policy <- policy in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_orientation o dir ~global =
  let apply (td : Types.Config.Data.t) = td.tiling.dir <- dir in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;

let set_wm_stack (o : t) ws =
  o.wm_stack <- ws;
  Schedule.manage ()
;;

let set_focus_stack (o : t) ws = o.focus_stack <- ws

let resolve_tag_arg (arg : Tag.Arg.t) (o : t) =
  match arg with
  | Concrete s -> s
  | Occupied -> occupied_tags o
;;

let to_vector (o : t) = Rect.to_int o.geom |> Vector.center
let matches_name name (o : t) = Option.fold ~none:false ~some:(fun s -> s = name) o.name

let resolve_output_logical ~(dir : Direction.Logical.t) (current : t) =
  match dir with
  | Next -> Ring.next_or_first current
  | Prev -> Ring.prev_or_last current
;;

let resolve_output_spatial ~from ~dir (current : t) =
  Vector.nearest_in_direction ~from ~dir (fun o ->
    if o == current then None else Some (to_vector o))
;;

let resolve_output_name name = List.find_opt (matches_name name)
let set_lifecycle (o : t) lifecycle = o.lifecycle <- lifecycle

let set_usable (o : t) usable =
  o.usable <- usable;
  Schedule.manage ()
;;

let set_name (o : t) name = o.name <- name
let set_geom (o : t) geom = o.geom <- geom
let set_scroll_offset (o : t) offset = o.scroll_offset <- offset

let set_default_width o (delta : float Delta.t) ~global =
  let apply (td : Types.Config.Data.t) =
    let f =
      match delta with
      | Abs a -> a
      | Rel r -> Width_fac.to_float td.scrolling.default_width +. r
    in
    td.scrolling.default_width <- Width_fac.of_float f
  in
  if global
  then Tag.Set.iter (fun i -> Tag.Set.singleton i |> tag_data o |> apply) Tag.Set.all
  else to_tag_data o |> apply;
  Schedule.manage ()
;;
