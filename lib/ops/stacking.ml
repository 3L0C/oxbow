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
    splice_focus_stack [ window ];
    sync seat
  | Push windows ->
    Output.set_wm_stack output @@ windows @ List.filter (not_in windows) output.wm_stack;
    splice_focus_stack windows
  | Remove w ->
    Output.set_wm_stack output @@ List.filter (fun w' -> w' != w) output.wm_stack;
    Output.set_focus_stack output @@ List.filter (fun w' -> w' != w) output.focus_stack
;;

let push windows output = apply (Push windows) output
let remove_window ~window output = apply (Remove window) output

let focus_window ctx seat window =
  Option.iter (apply @@ Promote { ctx; window; seat }) window.output
;;

let shift (seat : Seat.t) (dir : Direction.Logical.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let has_other =
      match o.wm_stack with
      | [] | [ _ ] -> false
      | _ -> true
    in
    (match Output.focused_window o, dir with
     | None, _ -> Error Messages.no_focused_window
     | Some _, _ when not has_other -> Error "no other window to shift"
     | Some w, Next ->
       Output.set_wm_stack o @@ Ring.shift_right (( == ) w) o.wm_stack;
       Ok None
     | Some w, Prev ->
       Output.set_wm_stack o @@ Ring.shift_left (( == ) w) o.wm_stack;
       Ok None)
;;
