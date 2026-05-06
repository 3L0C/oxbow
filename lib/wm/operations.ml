module Rwm = Ocdwm_protocol.River_window_management_v1_client

let seat_op (ctx : Ctx.manage Ctx.t) (s : Seat.t) =
  let wm = Ctx.wm ctx in
  match s.op with
  | Op_move op_m when op_m.release ->
    Rwm.River_seat_v1.op_end s.obj;
    let w = op_m.window in
    let cx = Int32.(div w.geom.w 2l |> add w.geom.x) in
    let cy = Int32.(div w.geom.h 2l |> add w.geom.y) in
    (match Output.at_point ~x:cx ~y:cy wm.outputs with
     | Some o when not @@ Utils.opt_holds w.output o ->
       let prev = w.output in
       Output.move_window w o;
       Option.iter Output.mark_dirty prev;
       Output.mark_dirty o
     | _ -> ());
    if op_m.window.presentation = P_floating && (not @@ Output.is_floating w.output)
    then Window.remember_float op_m.window;
    s.op <- Op_none
  | Op_resize op_r when op_r.release ->
    Rwm.River_window_v1.inform_resize_end op_r.window.obj;
    Rwm.River_seat_v1.op_end s.obj;
    if
      op_r.window.presentation = P_floating
      && (not @@ Output.is_floating op_r.window.output)
    then Window.remember_float op_r.window;
    s.op <- Op_none
  | Op_resize op_r ->
    let left = Int32.logand op_r.edges Rwm.River_window_v1.Edges.left <> 0l in
    let right = Int32.logand op_r.edges Rwm.River_window_v1.Edges.right <> 0l in
    let top = Int32.logand op_r.edges Rwm.River_window_v1.Edges.top <> 0l in
    let bottom = Int32.logand op_r.edges Rwm.River_window_v1.Edges.bottom <> 0l in
    let width =
      match left, right with
      | true, true | false, false -> op_r.start_w
      | true, false -> Int32.sub op_r.start_w op_r.dx
      | false, true -> Int32.add op_r.start_w op_r.dx
    in
    let height =
      match top, bottom with
      | true, true | false, false -> op_r.start_h
      | true, false -> Int32.sub op_r.start_h op_r.dy
      | false, true -> Int32.add op_r.start_h op_r.dy
    in
    Rwm.River_window_v1.propose_dimensions
      op_r.window.obj
      ~width:(max 1l width)
      ~height:(max 1l height)
  | Op_move op_m -> ()
  | Op_none -> ()
;;
