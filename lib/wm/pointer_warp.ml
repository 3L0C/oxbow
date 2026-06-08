open! Ocdwm_core

let center (g : int32 Rect.t) = Int32.(add g.x (div g.w 2l), add g.y (div g.h 2l))

let warp_to_focus (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  let wm = Ctx.wm ctx in
  if wm.config.warp_on_focus
  then (
    let target =
      match Focus.focused_of seat with
      | Some w -> Some w.geom
      | None -> Option.map (fun (o : Types.Output.t) -> o.geom) seat.output
    in
    match target with
    | None -> ()
    | Some g ->
      let x, y = center g in
      River.Window_management.River_seat_v1.pointer_warp seat.obj ~x ~y)
;;
