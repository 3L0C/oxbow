open! Oxbow_core
open! Oxbow_state
open! Oxbow_ops

let capabilities ctx w = Send.set_capabilities ctx w ~caps:Wire.Capabilities.fullscreen

let dimensions ctx (w : Window.t) =
  if w.float_seed_pending
  then Send.propose_dimensions ctx w ~width:0l ~height:0l
  else (
    match w.defense with
    | Bounce (bw, bh) when Output.arranges w ->
      Send.propose_dimensions ctx w ~width:bw ~height:bh;
      Window.set_defense w (Hold (bw, bh));
      Schedule.manage ()
    | Idle | Bounce _ | Hold _ ->
      Send.propose_dimensions ctx w ~width:w.geom.w ~height:w.geom.h)
;;

let decoration ctx w =
  let tiled = Window.is_tiled w in
  let edges =
    let open Wire in
    if tiled
    then Int32.(logor Edges.left Edges.right |> logor Edges.top |> logor Edges.bottom)
    else Edges.none
  in
  Send.set_tiled ctx w ~edges;
  match w.decoration_hint with
  | Some Only_csd -> ()
  | _ when tiled -> Send.use_ssd ctx w
  | Some Prefer_csd -> Send.use_csd ctx w
  | Some Prefer_ssd | Some No_preference | None -> Send.use_ssd ctx w
;;

let presentation ctx (w : Window.t) =
  let want_fullscreen_on =
    match w.presentation, w.output with
    | Fullscreen _, Some o -> Some o
    | Fullscreen _, None -> None
    | (Tiled | Floating | Maximized _), _ -> None
  in
  let want_maximized =
    match w.presentation with
    | Maximized _ -> true
    | Tiled | Floating | Fullscreen _ -> false
  in
  let want_informed_fullscreen = Window.is_fullscreen w || w.is_fake_fullscreen in
  if not want_maximized then Send.inform_unmaximized ctx w;
  if Option.is_none want_fullscreen_on then Send.exit_fullscreen ctx w;
  if not want_informed_fullscreen then Send.inform_not_fullscreen ctx w;
  want_fullscreen_on |> Option.iter (fun output -> Send.fullscreen ctx w ~output);
  if want_informed_fullscreen then Send.inform_fullscreen ctx w;
  if want_maximized then Send.inform_maximized ctx w
;;

let resizing ctx w =
  let wm = Ctx.wm ctx in
  let want_resizing =
    wm.seats
    |> List.exists (fun (s : Seat.t) ->
      match s.op with
      | Some (Resize { window; _ }) -> window == w
      | _ -> false)
  in
  if want_resizing then Send.inform_resize_start ctx w else Send.inform_resize_end ctx w
;;

let focus ctx (s : Seat.t) =
  let want = if s.focus_cleared then None else Seat.focused_window s in
  match want with
  | Some w -> Send.focus_window ctx s w
  | None -> Send.clear_focus ctx s
;;

let bindings ctx (s : Seat.t) =
  let active = if (Ctx.wm ctx).session_locked then Mode.locked else s.mode in
  List.iter
    (fun (b : Seat.Xkb_binding.t) ->
       let desired = Mode.equal b.mode active in
       match desired, b.enabled with
       | true, true | false, false -> ()
       | true, false ->
         Send.enable_xkb_binding ctx b.obj;
         b.enabled <- desired
       | false, true ->
         Send.disable_xkb_binding ctx b.obj;
         b.enabled <- desired)
    s.xkb_bindings;
  List.iter
    (fun (p : Seat.Pointer_binding.t) ->
       let desired = Mode.equal p.mode active in
       match desired, p.enabled with
       | true, true | false, false -> ()
       | true, false ->
         Send.enable_pointer_binding ctx p.obj;
         p.enabled <- desired
       | false, true ->
         Send.disable_pointer_binding ctx p.obj;
         p.enabled <- desired)
    s.pointer_bindings;
  Send.modifiers_watch ctx s
;;

let warp ctx (s : Seat.t) =
  let with_warp_request f =
    f s.warp_request;
    Seat.set_warp_request s No_request
  in
  let warp_to = function
    | `Point (x, y) -> Send.pointer_warp ctx s ~x ~y
    | `Focus ->
      Pointer.warp_target s |> Option.iter (fun (x, y) -> Send.pointer_warp ctx s ~x ~y)
  in
  with_warp_request
  @@ function
  | No_request -> ()
  | Forced b -> if b then warp_to `Focus
  | Follow_config -> if (Ctx.wm ctx).config.warp_on_focus then warp_to `Focus
  | Point p -> warp_to (`Point p)
;;

let op ctx (s : Seat.t) =
  match s.op with
  | Some (Move _ | Resize _) -> Send.op_start_pointer ctx s
  | None -> Send.op_end ctx s
;;

let close ctx (w : Window.t) =
  if w.close_pending
  then (
    Send.close ctx w;
    Window.set_close_pending w false)
;;

let manage_windows ctx windows =
  List.iter
    (fun w ->
       capabilities ctx w;
       dimensions ctx w;
       decoration ctx w;
       presentation ctx w;
       resizing ctx w;
       close ctx w)
    windows
;;

let manage_seats ctx seats =
  List.iter
    (fun s ->
       focus ctx s;
       bindings ctx s;
       warp ctx s;
       op ctx s)
    seats
;;

let manage ctx =
  let wm = Ctx.wm ctx in
  manage_windows ctx wm.windows;
  manage_seats ctx wm.seats
;;

let seat_op (seat : Seat.t) =
  match seat.op with
  | None -> ()
  | Some (Move op_m) ->
    Window.set_position
      op_m.window
      ~x:(Int32.add op_m.start_x op_m.dx)
      ~y:(Int32.add op_m.start_y op_m.dy)
  | Some (Resize op_r) ->
    let open Wire in
    let x =
      if Int32.logand op_r.edges Edges.left <> 0l
      then Int32.sub op_r.start_w op_r.window.geom.w |> Int32.add op_r.start_x
      else op_r.start_x
    in
    let y =
      if Int32.logand op_r.edges Edges.top <> 0l
      then Int32.sub op_r.start_h op_r.window.geom.h |> Int32.add op_r.start_y
      else op_r.start_y
    in
    Window.set_position op_r.window ~x ~y
;;

let borders ctx (seat : Seat.t) =
  let wm = Ctx.wm ctx in
  let borders = wm.config.borders in
  let focused = List.map (fun o -> o, Output.focused_window o) wm.outputs in
  let color (w : Window.t) o =
    if w.is_urgent
    then borders.urgent
    else if w.is_captured
    then borders.captured
    else if not @@ Phys.opt_holds o seat.output
    then borders.unfocused
    else if Window.swallowing w
    then borders.swallowing
    else if Phys.opt_holds w (List.assq_opt o focused |> Option.join)
    then borders.focused
    else borders.unfocused
  in
  let edges =
    let open Wire in
    Int32.(logor Edges.left Edges.right |> logor Edges.top |> logor Edges.bottom)
  in
  let width = borders.width in
  List.iter
    (fun (w : Window.t) ->
       match w.output with
       | None -> ()
       | Some o ->
         let w_width =
           match w.presentation with
           | Maximized _ | Fullscreen _ -> 0l
           | Tiled | Floating -> width
         in
         Send.set_borders ctx w ~edges ~width:w_width ~color:(color w o))
    wm.windows
;;

let node ctx covered (w : Window.t) =
  let wm = Ctx.wm ctx in
  (match w.presentation with
   | Fullscreen _ -> ()
   | Tiled | Floating | Maximized _ -> Send.set_position ctx w ~x:w.geom.x ~y:w.geom.y);
  let moving =
    wm.seats
    |> List.exists (fun (s : Seat.t) ->
      match s.op with
      | Some (Move { window; _ }) -> window == w
      | _ -> false)
  in
  let fullscreen =
    match w.output with
    | Some o -> List.assq_opt o covered |> Option.value ~default:false
    | None -> false
  in
  let rendered = Window.is_rendered ~fullscreen w in
  if rendered then Send.show ctx w else if not moving then Send.hide ctx w;
  let want_clip =
    match w.output with
    | None -> None
    | Some _ when not rendered -> None
    | Some o when o.overview.enabled -> w.clip
    | Some o when Output.current_layout o <> Scrolling -> None
    | Some _ when not @@ Window.is_tiled w -> None
    | Some _ -> w.clip
  in
  match want_clip with
  | Some (`Overview, r) ->
    let g = Rect.to_int32 r in
    Send.set_clip_box ctx w ~x:0l ~y:0l ~width:0l ~height:0l;
    Send.set_content_clip_box ctx w ~x:g.x ~y:g.y ~width:g.w ~height:g.h
  | Some (`Scrolling, r) ->
    let g = Rect.to_int32 r in
    Send.set_clip_box ctx w ~x:g.x ~y:g.y ~width:g.w ~height:g.h;
    Send.set_content_clip_box ctx w ~x:0l ~y:0l ~width:0l ~height:0l
  | None ->
    Send.set_clip_box ctx w ~x:0l ~y:0l ~width:0l ~height:0l;
    Send.set_content_clip_box ctx w ~x:0l ~y:0l ~width:0l ~height:0l
;;

let window_z_order ctx (output : Output.t) =
  let visible = List.filter Window.tag_visible output.focus_stack in
  let tiled, floating = List.partition Window.is_tiled visible in
  List.rev tiled |> List.iter (Send.place_top ctx);
  List.rev floating |> List.iter (Send.place_top ctx)
;;

let op_window_top ctx (seat : Seat.t) =
  match seat.op with
  | Some (Move { window; _ }) -> Send.place_top ctx window
  | _ -> ()
;;

let presentation_mode ctx output =
  match Output.focused_window output with
  | Some w when Option.is_some w.output ->
    let mode =
      match w.presentation_hint with
      | Some p -> p
      | None -> Wire.Presentation_mode.Vsync
    in
    Send.set_presentation_mode ctx output ~mode
  | _ -> Send.set_presentation_mode ctx output ~mode:Wire.Presentation_mode.Vsync
;;

let render_seats ctx seats =
  List.iter
    (fun s ->
       seat_op s;
       borders ctx s)
    seats
;;

let render_windows ctx windows =
  let wm = Ctx.wm ctx in
  let covered = List.map (fun o -> o, Output.has_visible_fullscreen o) wm.outputs in
  List.iter (node ctx covered) windows
;;

let render_outputs ctx outputs =
  List.iter
    (fun o ->
       window_z_order ctx o;
       presentation_mode ctx o)
    outputs
;;

let render_edge_cases ctx =
  let wm = Ctx.wm ctx in
  List.iter (fun s -> op_window_top ctx s) wm.seats
;;

let render ctx =
  let wm = Ctx.wm ctx in
  render_seats ctx wm.seats;
  render_windows ctx wm.windows;
  render_outputs ctx wm.outputs;
  render_edge_cases ctx
;;
