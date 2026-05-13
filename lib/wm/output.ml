module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
open! Ocdwm_core

type t = Types.Output.t

module Focus_intent = struct
  type t =
    | Promote of
        { ctx : Ctx.manage Ctx.t
        ; window : Types.Window.t
        ; seat : Types.Seat.t
        }
    | Push of Types.Window.t list
    | Remove of Types.Window.t
end

let focused_window (o : t) = List.find_opt Window.tag_visible o.focus_stack

let apply (intent : Focus_intent.t) (o : t) =
  let not_in lst w = not @@ List.memq w lst in
  let splice_focus_stack windows =
    match o.focus_stack with
    | w' :: xs when not_in windows w' && Window.is_fullscreen w' && Window.tag_visible w'
      -> o.focus_stack <- (w' :: windows) @ List.filter (not_in windows) xs
    | _ -> o.focus_stack <- windows @ List.filter (not_in windows) o.focus_stack
  in
  let sync (seat : Types.Seat.t) =
    match focused_window o with
    | None -> ()
    | Some w ->
      Rwm.River_seat_v1.focus_window seat.obj ~window:w.obj;
      Rwm.River_node_v1.place_top w.node
  in
  match intent with
  | Promote { window; seat; _ } ->
    splice_focus_stack [ window ];
    sync seat
  | Push windows ->
    o.windows <- windows @ List.filter (not_in windows) o.windows;
    splice_focus_stack windows
  | Remove w ->
    o.windows <- List.filter (fun w' -> w' != w) o.windows;
    o.focus_stack <- List.filter (fun w' -> w' != w) o.focus_stack
;;

let destroy (o : t) =
  Rlsh.River_layer_shell_output_v1.destroy o.layer_shell;
  Wayland.Proxy.delete o.layer_shell;
  Rwm.River_output_v1.destroy o.obj;
  Wayland.Proxy.delete o.obj
;;

let focus_window (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (window : Types.Window.t) =
  Option.iter (apply @@ Promote { ctx; window; seat }) window.output
;;

let next_tiled : Types.Window.t list -> Types.Window.t option =
  Utils.wrapped_search Window.tag_visible (fun w -> (Option.get w.output).windows)
;;

let prev_tiled : Types.Window.t list -> Types.Window.t option =
  Utils.wrapped_search Window.tag_visible (fun w ->
    (Option.get w.output).windows |> List.rev)
;;

let next_window (o : t) =
  match focused_window o with
  | None -> None
  | Some f ->
    let rec after = function
      | [ w ] when w == f -> next_tiled o.windows
      | w :: xs when w == f -> next_tiled xs
      | _ :: xs -> after xs
      | [] ->
        Logs.err (fun m -> m "Focused window isn't in output window list");
        None
    in
    after o.windows
;;

let prev_window (o : t) =
  match focused_window o with
  | None -> None
  | Some f ->
    let rec after = function
      | [ w ] when w == f -> List.rev o.windows |> prev_tiled
      | w :: xs when w == f -> prev_tiled xs
      | _ :: xs -> after xs
      | [] ->
        Logs.err (fun m -> m "Focused window isn't in output window list");
        None
    in
    List.rev o.windows |> after
;;

let remove_window ~(window : Types.Window.t) (o : t) = apply (Remove window) o

let tag_data (o : t) =
  match Tag_set.first o.selected_tags with
  | Some i -> o.tag_state.(i - 1)
  | None -> assert false
;;

let visible_window_count (o : t) =
  List.fold_left (fun a w -> if Window.tag_visible w then a + 1 else a) 0 o.windows
;;

let visible_windows (o : t) = List.filter Window.tag_visible o.windows

let tiled_windows (o : t) =
  List.filter (fun w -> Window.tag_visible w && Window.is_tiled w) o.windows
;;

let mark_dirty (wm : Types.Window_manager.t) (o : t) =
  o.state <- O_dirty { prev = o.state };
  Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let fullscreen_is_visible (o : t) =
  List.exists (fun w -> Window.is_fullscreen w && Window.tag_visible w) o.focus_stack
;;

let push (windows : Types.Window.t list) (o : t) = apply (Push windows) o

let move_window (w : Types.Window.t) (target : t) =
  let take () =
    w.output <- Some target;
    push [ w ] target
  in
  match w.output with
  | Some o when o == target -> ()
  | None -> take ()
  | Some o ->
    Option.iter (remove_window ~window:w) w.output;
    take ()
;;

let set_layout_entry (o : t) ~(entry : Layout_entry.t) =
  let td = tag_data o in
  td.layout_entry <- entry
;;

let current_layout_entry (o : t) =
  let td = tag_data o in
  td.layout_entry
;;

let current_layout_params (o : t) =
  let td = tag_data o in
  td.layout_params
;;

let retile (ctx : Ctx.manage Ctx.t) (o : t) =
  if not @@ fullscreen_is_visible o
  then (
    let windows = tiled_windows o in
    let count = List.length windows in
    let tag_data = tag_data o in
    let compute = Layout.compute ~entry:tag_data.layout_entry in
    let dimensions = compute ~data:tag_data.layout_params ~area:o.usable ~count in
    match windows, dimensions with
    | _, [] when count <> 0 ->
      List.iter (fun w -> Window.restore_or_seed_float ctx w) windows
    | _, d_xs when List.length d_xs <> count ->
      let layout_name = Layout.entry_name tag_data.layout_entry in
      Logs.warn (fun m ->
        m
          "retile skipped: layout %S returned unexpected geometry count. Expected %d, \
           got %d"
          layout_name
          count
          (List.length d_xs))
    | w_xs, d_xs ->
      List.iter2 (fun w g -> Window.clamp w g |> Window.set_geom ctx w) w_xs d_xs)
;;

let switch_tags (o : t) = function
  | tags when Tag_set.is_empty tags -> ()
  | tags when Tag_set.equal tags o.selected_tags -> ()
  | tags ->
    o.previous_tags <- o.selected_tags;
    o.selected_tags <- tags
;;

let occupied_tags (o : t) =
  List.fold_left
    (fun (s : Tag_set.t) (w : Types.Window.t) -> Tag_set.union s w.tags)
    Tag_set.empty
    o.windows
;;

let at_point ~(x : int32) ~(y : int32) =
  List.find_opt (fun (o : t) -> Utils.in_rect ~x ~y ~g:o.geom)
;;

let is_floating (output : t option) =
  match output with
  | None -> false
  | Some o ->
    let name = current_layout_entry o |> Layout.entry_name in
    name = Floating.name
;;

let set_mfact ~(delta : float Delta.t) (wm : Types.Window_manager.t) (o : t) =
  let layout_params = current_layout_params o in
  let mfact =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.mfact +. r
  in
  layout_params.mfact <- Float.(max 0.05 mfact |> min 0.95);
  mark_dirty wm o
;;

let set_nmaster ~(delta : int Delta.t) (wm : Types.Window_manager.t) (o : t) =
  let layout_params = current_layout_params o in
  let nmaster =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.nmaster + r
  in
  layout_params.nmaster <- max 0 nmaster;
  mark_dirty wm o
;;

let set_gaps_inner ~(delta : int Delta.t) (wm : Types.Window_manager.t) (o : t) =
  let layout_params = current_layout_params o in
  let gaps_inner =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.gaps_inner + r
  in
  layout_params.gaps_inner <- max 0 gaps_inner;
  mark_dirty wm o
;;

let set_gaps_outer ~(delta : int Delta.t) (wm : Types.Window_manager.t) (o : t) =
  let layout_params = current_layout_params o in
  let gaps_outer =
    match delta with
    | Delta.Abs a -> a
    | Delta.Rel r -> layout_params.gaps_outer + r
  in
  layout_params.gaps_outer <- max 0 gaps_outer;
  mark_dirty wm o
;;

let set_stack_kind ~(kind : Stack_kind.t) (wm : Types.Window_manager.t) (o : t) =
  let layout_params = current_layout_params o in
  layout_params.stack <- kind;
  mark_dirty wm o
;;

let rotate_window (dir : Direction.t) (o : t) =
  let open Direction in
  match focused_window o, dir with
  | None, _ -> ()
  | Some w, Dir_next | Some w, Dir_down | Some w, Dir_right ->
    o.windows <- Utils.rotate_right (( == ) w) o.windows
  | Some w, Dir_prev | Some w, Dir_up | Some w, Dir_left ->
    o.windows <- Utils.rotate_left (( == ) w) o.windows
;;

let resolve_tag_arg (arg : Tag_arg.t) (o : t) =
  let open Tag_arg in
  match arg with
  | Tags_concrete s -> s
  | Tags_occupied -> occupied_tags o
;;
