open! Oxbow_core
open! Oxbow_state

module Focus_intent = struct
  type t =
    | Promote of Window.t
    | Push of Window.t list
    | Remove of Window.t
end

let not_in lst w = not @@ List.memq w lst

let splice_focus_stack windows (output : Output.t) =
  match output.focus_stack with
  | w' :: xs when not_in windows w' && Window.is_fullscreen w' && Window.tag_visible w' ->
    Output.set_focus_stack output @@ (w' :: windows) @ List.filter (not_in windows) xs
  | _ ->
    Output.set_focus_stack output
    @@ windows
    @ List.filter (not_in windows) output.focus_stack
;;

let apply (intent : Focus_intent.t) (output : Output.t) =
  match intent with
  | Promote window ->
    if output.overview.enabled
    then (
      let changed =
        match output.overview.head with
        | Some w -> w != window
        | None -> true
      in
      Output.set_overview_head output (Some window);
      if changed then Schedule.manage ())
    else (
      let changed =
        match output.focus_stack with
        | hd :: _ -> hd != window
        | [] -> true
      in
      if changed then splice_focus_stack [ window ] output;
      if not @@ Window.tag_visible window then Output.switch_tags ~tags:window.tags output;
      if Output.current_layout output = Scrolling && changed then Schedule.manage ())
  | Push windows ->
    Output.set_wm_stack output @@ windows @ List.filter (not_in windows) output.wm_stack;
    splice_focus_stack windows output
  | Remove w ->
    Output.set_wm_stack output @@ List.filter (fun w' -> w' != w) output.wm_stack;
    Output.set_focus_stack output @@ List.filter (fun w' -> w' != w) output.focus_stack;
    if Phys.opt_holds w output.overview.head
    then
      List.find_opt Window.tag_visible output.focus_stack
      |> Output.set_overview_head output
;;

let push windows output = apply (Push windows) output

let spawn ~(position : Spawn_position.t) ~focus ~window (output : Output.t) =
  let stack = List.filter (( != ) window) output.wm_stack in
  let placed =
    match position, Output.focused_window output with
    | Master, _ | (Prev | Next), None -> window :: stack
    | End, _ -> stack @ [ window ]
    | Prev, Some f -> Ring.insert_relative ~after:false ~point:f ~e:window stack
    | Next, Some f -> Ring.insert_relative ~after:true ~point:f ~e:window stack
  in
  Output.set_wm_stack output placed;
  if focus
  then splice_focus_stack [ window ] output
  else (
    match output.focus_stack with
    | [] -> Output.set_focus_stack output [ window ]
    | w :: rest ->
      Output.set_focus_stack output @@ (w :: window :: List.filter (( != ) window) rest))
;;

let remove_window ~window output = apply (Remove window) output

let restore_focus_order ~like (output : Output.t) =
  let arrived = List.filter (fun w -> List.memq w output.focus_stack) like in
  let stayed = List.filter (fun w -> not @@ List.memq w like) output.focus_stack in
  Output.set_focus_stack output (arrived @ stayed)
;;

let focus_window window = Option.iter (apply (Promote window)) window.output

let shift wm seat target (dir : Direction.Logical.t) =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    With.output w
    @@ fun o ->
    if o.overview.enabled
    then Error "cannot shift the window stack from overview"
    else (
      let has_other = Output.visible_window_count o > 1 in
      match Output.focused_window o, dir with
      | None, _ -> Error Messages.no_focused_window
      | Some _, _ when not has_other -> Error "no other visible window to shift"
      | Some w, Next ->
        Ok
          (fun () ->
            Output.set_wm_stack o
            @@ Ring.hop_right (( == ) w) Window.tag_visible o.wm_stack)
      | Some w, Prev ->
        Ok
          (fun () ->
            Output.set_wm_stack o
            @@ Ring.hop_left (( == ) w) Window.tag_visible o.wm_stack)))
;;

let replace ~old_w ~new_w (output : Output.t) =
  let swap =
    List.filter_map (fun w ->
      if w == new_w then None else if w == old_w then Some new_w else Some w)
  in
  Output.set_wm_stack output @@ swap output.wm_stack;
  Output.set_focus_stack output @@ swap output.focus_stack
;;
