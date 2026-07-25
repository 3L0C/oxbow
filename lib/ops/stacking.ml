open! Ocdwm_core
open! Ocdwm_state

module Focus_intent = struct
  type t =
    | Promote of
        { ctx : Ctx.manage Ctx.t
        ; window : Window.t
        ; seat : Seat.t
        }
    | Push of Window.t list
    | Remove of Window.t
end

let apply (intent : Focus_intent.t) (output : Output.t) =
  let not_in lst w = not @@ List.memq w lst in
  let splice_focus_stack windows =
    match output.focus_stack with
    | w' :: xs when not_in windows w' && Window.is_fullscreen w' && Window.tag_visible w'
      ->
      Output.set_focus_stack output @@ (w' :: windows) @ List.filter (not_in windows) xs
    | _ ->
      Output.set_focus_stack output
      @@ windows
      @ List.filter (not_in windows) output.focus_stack
  in
  let sync (seat : Seat.t) =
    match Output.focused_window output with
    | None -> ()
    | Some w ->
      River.Window_management.River_seat_v1.focus_window seat.obj ~window:w.obj;
      River.Window_management.River_node_v1.place_top w.node
  in
  match intent with
  | Promote { window; seat; _ } ->
    let changed =
      match output.focus_stack with
      | hd :: _ -> hd != window
      | [] -> true
    in
    splice_focus_stack [ window ];
    if not @@ Tag.Set.intersects window.tags output.selected_tags
    then Output.switch_tags ~tags:window.tags output;
    sync seat;
    if Output.current_layout output = Scrolling && changed then Schedule.manage ()
  | Push windows ->
    Output.set_wm_stack output @@ windows @ List.filter (not_in windows) output.wm_stack;
    splice_focus_stack windows
  | Remove w ->
    Output.set_wm_stack output @@ List.filter (fun w' -> w' != w) output.wm_stack;
    Output.set_focus_stack output @@ List.filter (fun w' -> w' != w) output.focus_stack
;;

let push windows output = apply (Push windows) output
let remove_window ~window output = apply (Remove window) output

let restore_focus_order ~like (output : Output.t) =
  let arrived = List.filter (fun w -> List.memq w output.focus_stack) like in
  let stayed = List.filter (fun w -> not @@ List.memq w like) output.focus_stack in
  Output.set_focus_stack output (arrived @ stayed)
;;

let focus_window ctx seat window =
  Option.iter (apply @@ Promote { ctx; window; seat }) window.output
;;

let shift (seat : Seat.t) (dir : Direction.Logical.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let has_other = Output.visible_window_count o > 1 in
    (match Output.focused_window o, dir with
     | None, _ -> Error Messages.no_focused_window
     | Some _, _ when not has_other -> Error "no other visible window to shift"
     | Some w, Next ->
       Output.set_wm_stack o @@ Ring.hop_right (( == ) w) Window.tag_visible o.wm_stack;
       Ok None
     | Some w, Prev ->
       Output.set_wm_stack o @@ Ring.hop_left (( == ) w) Window.tag_visible o.wm_stack;
       Ok None)
;;

let raise_floats (_ : Ctx.manage Ctx.t) (output : Output.t) =
  output.focus_stack
  |> List.filter (fun w -> Window.tag_visible w && w.presentation = Floating)
  |> List.rev
  |> List.iter (fun (w : Window.t) ->
    River.Window_management.River_node_v1.place_top w.node)
;;
