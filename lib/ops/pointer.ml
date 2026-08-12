open! Oxbow_core
open! Oxbow_state
open! Oxbow_ipc

let follow_allowed (policy : Focus_follows_policy.t) (w : Window.t) =
  match policy with
  | Always -> true
  | Never -> false
  | Not_scrolling -> not @@ Window.scroll_clipped w
;;

let handle_position (wm : Wm.t) (seat : Seat.t) (x, y) =
  let pos_changed = seat.position <> { x; y } in
  Seat.set_position seat (x, y);
  if wm.config.focus_follows_pointer <> Never && Option.is_none seat.op
  then (
    match Output.at_point ~x ~y wm.outputs with
    | None -> Seat.set_cursor_target seat None
    | Some o ->
      if not @@ Phys.opt_holds o seat.output then Seat.focus_output seat @@ Some o;
      (match seat.hovered with
       | Some w
         when (not @@ Phys.opt_holds w seat.cursor_target)
              && follow_allowed wm.config.focus_follows_pointer w ->
         if pos_changed then Seat.set_focus_state seat @@ Refresh w;
         Seat.set_cursor_target seat seat.hovered
       | _ -> ()))
;;

let warp_target seat =
  let center (g : int32 Rect.t) = Int32.(add g.x (div g.w 2l), add g.y (div g.h 2l)) in
  let target =
    match Seat.focused_window seat with
    | Some w -> Some w.geom
    | None -> Option.map (fun (o : Output.t) -> o.geom) seat.output
  in
  match target with
  | None -> None
  | Some g -> Some (center g)
;;

let handle wm _seat (cmd : Command.Input.Pointer.t) =
  let () =
    match cmd with
    | Follow policy -> Config.set_focus_follows_pointer wm policy
    | Cycle_follow ->
      Focus_follows_policy.cycle wm.config.focus_follows_pointer
      |> Config.set_focus_follows_pointer wm
    | Warp b -> Config.set_warp_on_focus wm b
    | Toggle_warp -> Config.set_warp_on_focus wm @@ not wm.config.warp_on_focus
  in
  Ok None
;;
