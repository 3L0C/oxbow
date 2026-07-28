open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ipc

let handle_position ~x ~y (wm : Wm.t) seat =
  Seat.set_position seat { x; y };
  if wm.config.focus_follows_pointer && Option.is_none seat.op
  then (
    match Output.at_point ~x ~y wm.outputs with
    | None -> Seat.set_cursor_target seat None
    | Some o ->
      if not @@ Phys.opt_holds o seat.output then Seat.focus_output seat @@ Some o;
      (match seat.hovered with
       | Some w when not @@ Phys.opt_holds w seat.cursor_target ->
         Seat.set_focus_state seat @@ Refresh w;
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
    | Follow b -> Config.set_focus_follows_pointer wm b
    | Toggle_follow ->
      Config.set_focus_follows_pointer wm @@ not wm.config.focus_follows_pointer
    | Warp b -> Config.set_warp_on_focus wm b
    | Toggle_warp -> Config.set_warp_on_focus wm @@ not wm.config.warp_on_focus
  in
  Ok None
;;
