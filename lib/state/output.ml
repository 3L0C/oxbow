open! Ocdwm_core
open! Ocdwm_layout
module Lifecycle = Types.Output.Lifecycle

type t = Types.Output.t

let focused_window (o : t) = List.find_opt Window.tag_visible o.focus_stack

let destroy (o : t) =
  River.Layer_shell.River_layer_shell_output_v1.destroy o.layer_shell;
  River.Window_management.River_output_v1.destroy o.obj;
  Wayland.Proxy.delete o.obj
;;

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

let to_tag_data (o : t) =
  match Tag.Set.first o.selected_tags with
  | Some i -> o.tag_data.(i - 1)
  | None -> invalid_arg "Got an output with no selected tags."
;;

let visible_window_count (o : t) =
  List.fold_left (fun a w -> if Window.tag_visible w then a + 1 else a) 0 o.wm_stack
;;

let visible_windows (o : t) = List.filter Window.tag_visible o.wm_stack

let tiled_windows (o : t) =
  List.filter (fun w -> Window.tag_visible w && Window.is_tiled w) o.wm_stack
;;

let set_layout_entry ~entry o =
  let td = to_tag_data o in
  td.entry <- entry;
  Dirty.mark_output o
;;

let current_layout_entry o =
  let td = to_tag_data o in
  td.entry
;;

let current_layout_params o =
  let td = to_tag_data o in
  td.params
;;

let current_layout_ctx o =
  match focused_window o with
  | None -> Symbol.Ctx.{ focused_index = 0; count = 0 }
  | Some w ->
    let ws = visible_windows o in
    let count = List.length ws in
    let focused_index =
      List.find_mapi (fun i w' -> if w == w' then Some i else None) ws
      |> Option.value ~default:0
    in
    Symbol.Ctx.{ focused_index; count }
;;

let switch_tags ~tags (o : t) =
  if not (Tag.Set.is_empty tags || Tag.Set.equal tags o.selected_tags)
  then (
    o.previous_tags <- o.selected_tags;
    o.selected_tags <- tags;
    Dirty.mark_output o)
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

let at_point ~x ~y = List.find_opt (fun (o : t) -> Rect.contains ~x ~y o.geom)

let has_visible_fullscreen (o : Types.Output.t) =
  List.exists (fun w -> Window.is_fullscreen w && Window.tag_visible w) o.focus_stack
;;

let is_floating output =
  match output with
  | None -> false
  | Some o ->
    let name = current_layout_entry o |> Entry.name in
    name = Floating.name
;;

let set_mfact o (delta : float Delta.t) =
  let layout_params = current_layout_params o in
  let mfact =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.mfact +. r
  in
  layout_params.mfact <- Float.(max 0.05 mfact |> min 0.95);
  Dirty.mark_output o
;;

let set_nmaster o (delta : int Delta.t) =
  let layout_params = current_layout_params o in
  let nmaster =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.nmaster + r
  in
  layout_params.nmaster <- max 0 nmaster;
  Dirty.mark_output o
;;

let set_gaps_inner o (delta : int Delta.t) =
  let layout_params = current_layout_params o in
  let gaps_inner =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.gaps_inner + r
  in
  layout_params.gaps_inner <- max 0 gaps_inner;
  Dirty.mark_output o
;;

let set_gaps_outer o (delta : int Delta.t) =
  let layout_params = current_layout_params o in
  let gaps_outer =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.gaps_outer + r
  in
  layout_params.gaps_outer <- max 0 gaps_outer;
  Dirty.mark_output o
;;

let set_stack o kind =
  let params = current_layout_params o in
  params.stack <- kind;
  Dirty.mark_output o
;;

let set_dir o dir =
  let params = current_layout_params o in
  params.dir <- dir;
  Dirty.mark_output o
;;

let set_wm_stack (o : t) ws =
  o.wm_stack <- ws;
  Dirty.mark_output o
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
  Dirty.mark_output o
;;

let set_name (o : t) name = o.name <- name
let set_geom (o : t) geom = o.geom <- geom

let set_arrangement (o : t) a =
  o.arrangement <- a;
  Dirty.mark_output o
;;

let is_dirty (o : t) =
  match o.lifecycle with
  | Dirty _ -> true
  | _ -> false
;;
