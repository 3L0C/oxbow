open! Ocdwm_core
open! Ocdwm_state

let begin_move ctx seat window =
  Focus.focus_window ctx seat window;
  Send.op_start_pointer ctx seat;
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

let begin_resize ctx seat window edges =
  Focus.focus_window ctx seat window;
  let g = window.geom in
  let open River.Window_management.River_window_v1 in
  let corner_x = if Int32.logand edges Edges.left <> 0l then g.x else Int32.add g.x g.w in
  let corner_y = if Int32.logand edges Edges.top <> 0l then g.y else Int32.add g.y g.h in
  Send.pointer_warp ctx seat ~x:corner_x ~y:corner_y;
  Send.inform_resize_start ctx window;
  Send.op_start_pointer ctx seat;
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

let step ctx (seat : Seat.t) =
  let wm = Ctx.wm ctx in
  match seat.op with
  | Some (Move op_m) when op_m.release ->
    Send.op_end ctx seat;
    let w = op_m.window in
    let cx = Int32.(div w.geom.w 2l |> add w.geom.x) in
    let cy = Int32.(div w.geom.h 2l |> add w.geom.y) in
    (match Output.at_point ~x:cx ~y:cy wm.outputs with
     | Some o when not @@ Phys.opt_holds o w.output ->
       Placement.move_window ctx w o ~policy:Tag.Policy.Take;
       Focus.focus_window ctx seat w;
       Schedule.manage ()
     | _ -> ());
    if op_m.window.presentation = Floating && (not @@ Output.is_floating w.output)
    then Window.remember_float op_m.window;
    Seat.clear_op seat
  | Some (Resize op_r) when op_r.release ->
    Send.inform_resize_end ctx op_r.window;
    Send.op_end ctx seat;
    if
      op_r.window.presentation = Floating && (not @@ Output.is_floating op_r.window.output)
    then Window.remember_float op_r.window;
    Seat.clear_op seat
  | Some (Resize op_r) ->
    let open River.Window_management.River_window_v1 in
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
    Window.propose_dimensions
      ctx
      op_r.window
      ~width:(max 1l width)
      ~height:(max 1l height)
  | Some (Move _) -> ()
  | None -> ()
;;
