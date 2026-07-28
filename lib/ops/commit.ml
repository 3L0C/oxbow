open! Ocdwm_core
open! Ocdwm_state

let capabilities ctx w =
  Send.set_capabilities ctx w ~caps:Wire.Capabilities.(Int32.logor maximize fullscreen)
;;

let dimensions ctx (w : Window.t) =
  if w.float_seed_pending
  then Send.propose_dimensions ctx w ~width:0l ~height:0l
  else Send.propose_dimensions ctx w ~width:w.geom.w ~height:w.geom.h
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

let node ctx (w : Window.t) =
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
  let rendered = Window.is_rendered w in
  if rendered then Send.show ctx w else if not moving then Send.hide ctx w;
  let want_clip =
    match w.output with
    | None -> None
    | Some o when o.overview -> None
    | Some o when Output.current_layout o <> Scrolling -> None
    | Some _ when not @@ Window.is_tiled w -> None
    | Some _ when not rendered -> None
    | Some _ -> w.clip
  in
  match want_clip with
  | Some r ->
    let g = Rect.to_int32 r in
    Send.set_clip_box ctx w ~x:g.x ~y:g.y ~width:g.w ~height:g.h
  | None -> Send.set_clip_box ctx w ~x:0l ~y:0l ~width:0l ~height:0l
;;
