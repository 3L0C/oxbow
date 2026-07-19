open! Ocdwm_core
open! Ocdwm_state

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

let warp_to_focus ctx seat =
  let center (g : int32 Rect.t) = Int32.(add g.x (div g.w 2l), add g.y (div g.h 2l)) in
  let wm = Ctx.wm ctx in
  if wm.config.warp_on_focus
  then (
    let target =
      match Seat.focused_window seat with
      | Some w -> Some w.geom
      | None -> Option.map (fun (o : Output.t) -> o.geom) seat.output
    in
    match target with
    | None -> ()
    | Some g ->
      let x, y = center g in
      River.Window_management.River_seat_v1.pointer_warp seat.obj ~x ~y)
;;
