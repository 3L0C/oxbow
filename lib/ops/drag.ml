open! Oxbow_core
open! Oxbow_state
open! Oxbow_layout

let begin_move wm seat window ~from_tiled =
  Focus.focus_window wm seat window;
  Seat.set_op seat
  @@ Move
       { window
       ; from_tiled
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

let widen_to_column ~(dir : Direction.Spatial.t) (cursor : Vector.t) tiled = function
  | Some ((w : Window.t), _) ->
    let cols =
      Strip.columns ~consumes:(fun (w : Window.t) -> w.scrolling.consumes) tiled
    in
    let col = List.find (List.memq w) cols in
    let center = Rect.to_int w.geom |> Vector.center in
    let head = List.hd col in
    let toward_head =
      match dir with
      | Left -> cursor.x < center.x
      | Right -> cursor.x > center.x
      | Up -> cursor.y < center.y
      | Down -> cursor.y > center.y
    in
    if toward_head then Some (head, `Before) else Some (List.rev col |> List.hd, `After)
  | None -> None
;;

let retile ~(window : Window.t) ~x ~y (o : Output.t) =
  let tiled = Output.tiled_windows o in
  let cursor : Vector.t = Int32.{ x = to_int x; y = to_int y } in
  let center (w : Window.t) = Vector.center (Rect.to_int w.geom) in
  let side w =
    match Vector.diff (center w) cursor |> Vector.direction with
    | Some (Left | Up) -> `Before
    | _ -> `After
  in
  let nearest () =
    List.fold_left
      (fun acc w ->
         let length = Vector.diff (center w) cursor |> Vector.length_squared in
         match acc with
         | None -> Some (length, w)
         | Some (length', _) when length < length' -> Some (length, w)
         | Some _ -> acc)
      None
      tiled
  in
  let target =
    let target' =
      match List.find_opt (fun (w : Window.t) -> Rect.contains ~x ~y w.geom) tiled with
      | Some w -> Some (w, side w)
      | None ->
        (match nearest () with
         | None -> None
         | Some (_, w) -> Some (w, side w))
    in
    if Output.current_layout o = Scrolling
    then widen_to_column ~dir:(Output.to_tag_data o).scrolling.dir cursor tiled target'
    else target'
  in
  let stack = List.filter (( != ) window) o.wm_stack in
  let placed =
    match target with
    | None -> window :: stack
    | Some (t, side) ->
      let after =
        match side with
        | `Before -> false
        | `After -> true
      in
      Ring.insert_relative ~after ~point:t ~e:window stack
  in
  Output.set_wm_stack o placed;
  Window.set_presentation window Tiled;
  Schedule.manage ()
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
    (match w.output with
     | Some o
       when wm.config.drag_retile
            && op_m.from_tiled
            && (not @@ Output.is_floating (Some o)) ->
       retile ~window:w ~x:seat.position.x ~y:seat.position.y o
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
    let hints = op_r.window.size_hints in
    let wall ~hint_min ~hint_max v =
      let min_v = if hint_min > 0l then hint_min else 50l in
      let v = Int32.max min_v v in
      if hint_max > 0l then Int32.min hint_max v else v
    in
    Window.set_geom
      op_r.window
      { op_r.window.geom with
        w = wall ~hint_min:hints.min_w ~hint_max:hints.max_w width
      ; h = wall ~hint_min:hints.min_h ~hint_max:hints.max_h height
      }
  | Some (Move _) -> ()
  | None -> ()
;;
