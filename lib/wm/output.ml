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
      River.Window_management.River_seat_v1.focus_window seat.obj ~window:w.obj;
      River.Window_management.River_node_v1.place_top w.node
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
  River.Layer_shell.River_layer_shell_output_v1.destroy o.layer_shell;
  River.Window_management.River_output_v1.destroy o.obj;
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
        (Logs.err @@ fun m -> m "Focused window isn't in output window list");
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
        (Logs.err @@ fun m -> m "Focused window isn't in output window list");
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
  match o.state with
  | O_dirty _ -> ()
  | _ ->
    o.state <- O_dirty { prev = o.state };
    River.Window_management.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let fullscreen_is_visible (o : t) =
  List.exists (fun w -> Window.is_fullscreen w && Window.tag_visible w) o.focus_stack
;;

let push (windows : Types.Window.t list) (o : t) = apply (Push windows) o

let move_window ?(policy = Tag_policy.Tag_keep) (w : Types.Window.t) (target : t) =
  let take () =
    w.output <- Some target;
    push [ w ] target;
    match policy with
    | Tag_keep -> ()
    | Tag_take ->
      w.tags
      <- Tag_set.first target.selected_tags
         |> Option.fold ~none:w.tags ~some:Tag_set.singleton
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
      Logs.warn
      @@ fun m ->
      m
        "retile skipped: layout %S returned unexpected geometry count. Expected %d, got \
         %d"
        layout_name
        count
        (List.length d_xs)
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

let shift (dir : Logical_direction.t) (o : t) =
  let open Logical_direction in
  match focused_window o, dir with
  | None, _ -> ()
  | Some w, Next -> o.windows <- Utils.shift_right (( == ) w) o.windows
  | Some w, Prev -> o.windows <- Utils.shift_left (( == ) w) o.windows
;;

let resolve_tag_arg (arg : Tag_arg.t) (o : t) =
  let open Tag_arg in
  match arg with
  | Tags_concrete s -> s
  | Tags_occupied -> occupied_tags o
;;

let to_vector (o : t) = Rect.to_int o.geom |> Vector.position_of_box

let send_to
      (ctx : Ctx.manage Ctx.t)
      (src : t)
      (dst : t)
      (window : Types.Window.t)
      (policy : Tag_policy.t)
  =
  let wm = Ctx.wm ctx in
  move_window ~policy window dst;
  (match window.presentation with
   | P_tiled -> ()
   | P_floating ->
     let dx = Int32.sub dst.geom.x src.geom.x in
     let dy = Int32.sub dst.geom.y src.geom.y in
     Window.set_position
       ctx
       window
       ~x:(Int32.add window.geom.x dx)
       ~y:(Int32.add window.geom.y dy);
     Window.fit_to_output ctx window;
     Window.remember_float window
   | P_maximized { restore } -> Window.maximize ~restore ctx window
   | P_fullscreen _ -> Window.fullscreen ~force:true ctx window);
  mark_dirty wm src;
  mark_dirty wm dst
;;

let resolve_output_logical (dir : Logical_direction.t) current l =
  match dir with
  | Next -> Utils.next_or_first current l
  | Prev -> Utils.prev_or_last current l
;;

let send_to_logical
      (ctx : Ctx.manage Ctx.t)
      (window : Types.Window.t)
      (dir : Logical_direction.t)
      (policy : Tag_policy.t)
  =
  let wm = Ctx.wm ctx in
  match window.output with
  | None -> ()
  | Some current ->
    let target = resolve_output_logical dir current wm.outputs in
    (match target with
     | Some o when o != current -> send_to ctx current o window policy
     | _ -> ())
;;

let resolve_output_spatial ~from ~dir ~current =
  Vector.nearest_in_direction ~from ~dir (fun (o : t) ->
    if o == current then None else Some (to_vector o))
;;

let send_to_spatial
      (ctx : Ctx.manage Ctx.t)
      (window : Types.Window.t)
      (dir : Spatial_direction.t)
      (policy : Tag_policy.t)
  =
  let wm = Ctx.wm ctx in
  match window.output with
  | None -> ()
  | Some current ->
    let from = to_vector current in
    let target = resolve_output_spatial ~from ~dir ~current wm.outputs in
    (match target with
     | Some o when o != current -> send_to ctx current o window policy
     | _ -> ())
;;

let matches_name name (o : t) = Option.fold ~none:false ~some:(fun s -> s = name) o.name
let resolve_output_name ~name = List.find_opt (matches_name name)

let send_to_name
      (ctx : Ctx.manage Ctx.t)
      (window : Types.Window.t)
      (name : string)
      (policy : Tag_policy.t)
  =
  let wm = Ctx.wm ctx in
  match window.output with
  | None -> ()
  | Some current when matches_name name current -> ()
  | Some current ->
    let target = resolve_output_name ~name wm.outputs in
    (match target with
     | Some o when o != current -> send_to ctx current o window policy
     | _ -> ())
;;
