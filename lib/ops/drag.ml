open! Ocdwm_core
open! Ocdwm_state

let begin_move wm seat window =
  Focus.focus_window wm seat window;
  Seat.set_op seat
  @@ Move
       { window
       ; start_x = window.geom.x
       ; start_y = window.geom.y
       ; dx = 0l
       ; dy = 0l
       ; release = false
       }
;;

let begin_resize wm seat window edges =
  Focus.focus_window wm seat window;
  let g = window.geom in
  let open Wire in
  Seat.set_warp_request seat
  @@ Point
       Int32.(
         ( (if logand edges Edges.left <> 0l then g.x else add g.x g.w)
         , if logand edges Edges.top <> 0l then g.y else add g.y g.h ));
  Seat.set_op seat
  @@ Resize
       { window
       ; edges
       ; start_x = window.geom.x
       ; start_y = window.geom.y
       ; start_w = window.geom.w
       ; start_h = window.geom.h
       ; dx = 0l
       ; dy = 0l
       ; release = false
       }
;;

let step (wm : Wm.t) (seat : Seat.t) =
  match seat.op with
  | Some (Move op_m) when op_m.release ->
    let w = op_m.window in
    let cx = Int32.(div w.geom.w 2l |> add w.geom.x) in
    let cy = Int32.(div w.geom.h 2l |> add w.geom.y) in
    (match Output.at_point ~x:cx ~y:cy wm.outputs with
     | Some o when not @@ Phys.opt_holds o w.output ->
       Placement.move_window w o ~policy:Tag.Policy.Take;
       Focus.focus_window wm seat w;
       Schedule.manage ()
     | _ -> ());
    if op_m.window.presentation = Floating && (not @@ Output.is_floating w.output)
    then Window.remember_float op_m.window;
    Seat.clear_op seat
  | Some (Resize op_r) when op_r.release ->
    if
      op_r.window.presentation = Floating && (not @@ Output.is_floating op_r.window.output)
    then Window.remember_float op_r.window;
    Seat.clear_op seat
  | Some (Resize op_r) ->
    let open Wire in
    let left = Int32.logand op_r.edges Edges.left <> 0l in
    let right = Int32.logand op_r.edges Edges.right <> 0l in
    let top = Int32.logand op_r.edges Edges.top <> 0l in
    let bottom = Int32.logand op_r.edges Edges.bottom <> 0l in
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
    Window.set_geom
      op_r.window
      { op_r.window.geom with w = max 1l width; h = max 1l height }
  | Some (Move _) -> ()
  | None -> ()
;;
