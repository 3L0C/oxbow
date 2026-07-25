open! Ocdwm_core
open! Ocdwm_state

let layer_shell_sync (wm : Wm.t) =
  match Wm.focused_output wm with
  | None -> ()
  | Some o -> River.Layer_shell.River_layer_shell_output_v1.set_default o.layer_shell
;;

let set_output ctx seat output =
  let wm = Ctx.wm ctx in
  Seat.set_output seat output;
  if Phys.opt_holds seat wm.primary_seat then layer_shell_sync wm
;;

let focus_window ?(force : bool = false) ?warp ctx (seat : Seat.t) (target : Window.t) =
  let force = force || Option.is_some seat.layer_focus in
  match Seat.focused_window seat with
  | Some w when w == target && not force -> ()
  | _ ->
    set_output ctx seat target.output;
    Stacking.focus_window ctx seat target;
    Option.iter (Seat.set_warp_request seat) warp
;;

let clear (_ : Ctx.manage Ctx.t) (seat : Seat.t) =
  River.Window_management.River_seat_v1.clear_focus seat.obj
;;

let refresh ctx output =
  let wm = Ctx.wm ctx in
  let target = Output.focused_window output in
  List.iter
    (fun (s : Seat.t) ->
       match s.output with
       | Some o when o == output ->
         (match target with
          | Some w -> focus_window ~force:true ctx s w
          | None -> clear ctx s)
       | _ -> ())
    wm.seats
;;

let refresh_layer_shell ctx (seat : Seat.t) =
  if Option.is_none seat.layer_focus
  then (
    match Seat.focused_window seat with
    | Some w -> focus_window ~force:true ctx seat w
    | None -> clear ctx seat)
;;

let window_logical ?warp ctx seat (dir : Direction.Logical.t) =
  match Seat.focused_window seat, seat.output with
  | Some w, _ when Window.is_fullscreen w -> Error Messages.window_is_fullscreen
  | _, None -> Error Messages.seat_missing_output
  | _, Some o ->
    let target =
      match dir with
      | Next -> Output.next_window o
      | Prev -> Output.prev_window o
    in
    (match target with
     | None -> Error "no window to focus"
     | Some w ->
       focus_window ~warp:(Seat.Warp_request.of_override warp) ctx seat w;
       Ok None)
;;

let window_spatial ?warp ctx seat (dir : Direction.Spatial.t) =
  match Seat.focused_window seat, seat.output with
  | Some w, _ when Window.is_fullscreen w -> Error Messages.window_is_fullscreen
  | _, None -> Error Messages.seat_missing_output
  | None, Some _ -> Error Messages.no_focused_window
  | Some current, Some o ->
    let from = Vector.center (Rect.to_int current.geom) in
    let target =
      Vector.nearest_in_direction
        ~from
        ~dir
        (fun (w : Window.t) ->
           if w == current || (not @@ Window.is_tiled w) || (not @@ Window.tag_visible w)
           then None
           else Some (Rect.to_int w.geom |> Vector.center))
        o.wm_stack
    in
    (match target with
     | None -> Error (Printf.sprintf "no window %s" (Direction.Spatial.to_string dir))
     | Some w ->
       focus_window ~warp:(Seat.Warp_request.of_override warp) ctx seat w;
       Ok None)
;;

let window_match ?warp ~cycle ctx seat m =
  let wm = Ctx.wm ctx in
  match Window_match.compile m with
  | Error e -> Error e
  | Ok matches ->
    (match Window_scope.filter wm seat m.scope with
     | Error e -> Error e
     | Ok windows ->
       let matching =
         List.find_all
           (fun (w : Window.t) ->
              matches ~title:w.title ~app_id:w.app_id ~identifier:w.identifier)
           windows
       in
       let target =
         match Seat.focused_window seat with
         | Some w
           when cycle && matches ~title:w.title ~app_id:w.app_id ~identifier:w.identifier
           -> Ring.next_or_first w matching
         | _ -> List.nth_opt matching 0
       in
       (match target with
        | None ->
          Error (Printf.sprintf "no window matches: %S" (Window_match.to_string m))
        | Some w ->
          focus_window ~force:true ~warp:(Seat.Warp_request.of_override warp) ctx seat w;
          Ok None))
;;

let focus_output ?warp ctx seat output =
  set_output ctx seat @@ Some output;
  Seat.(Warp_request.of_override warp |> set_warp_request seat);
  match Output.focused_window output with
  | Some w -> focus_window ctx seat w
  | None -> clear ctx seat
;;

let output_logical ?warp ctx (seat : Seat.t) (dir : Direction.Logical.t) =
  let wm = Ctx.wm ctx in
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let target =
      match dir with
      | Next -> Ring.next_or_first o wm.outputs
      | Prev -> Ring.prev_or_last o wm.outputs
    in
    (match target with
     | Some t when t != o ->
       focus_output ?warp ctx seat t;
       Ok None
     | _ -> Error Messages.no_other_output)
;;

let output_spatial ?warp ctx (seat : Seat.t) (dir : Direction.Spatial.t) =
  let wm = Ctx.wm ctx in
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some current ->
    let from = Output.to_vector current in
    let target =
      Vector.nearest_in_direction
        ~from
        ~dir
        (fun (o : Output.t) -> if o == current then None else Some (Output.to_vector o))
        wm.outputs
    in
    (match target with
     | None -> Error (Printf.sprintf "no output %s" (Direction.Spatial.to_string dir))
     | Some o ->
       focus_output ?warp ctx seat o;
       Ok None)
;;

let output_name ?warp ctx (seat : Seat.t) (name : string) =
  let wm = Ctx.wm ctx in
  match
    List.find_opt
      (fun (o : Output.t) -> Option.fold ~none:false ~some:(fun n -> n = name) o.name)
      wm.outputs
  with
  | None -> Error (Printf.sprintf "no output named %S" name)
  | Some o ->
    (match seat.output with
     | None -> focus_output ?warp ctx seat o
     | Some o' when o != o' -> focus_output ?warp ctx seat o
     | _ -> ());
    Ok None
;;

let focus_parent (child : Window.t) =
  match child.parent with
  | Some ({ lifecycle = New | Active; _ } as p) ->
    With.output_log child @@ fun o -> Stacking.restore_focus_order ~like:[ p ] o
  | _ -> ()
;;

let remove_window ctx (window : Window.t) =
  let was_focused =
    match window.output with
    | Some o -> Phys.opt_holds window (Output.focused_window o)
    | None -> false
  in
  Option.iter (Stacking.remove_window ~window) window.output;
  if was_focused then focus_parent window;
  Option.iter (refresh ctx) window.output
;;

let wm_sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  let default = Wm.default_output wm in
  List.iter
    (fun (s : Seat.t) ->
       match s.output with
       | Some o when not @@ List.memq o wm.outputs -> set_output ctx s default
       | None when not @@ List.is_empty wm.outputs -> set_output ctx s default
       | _ -> ())
    wm.seats;
  List.iter
    (fun (w : Window.t) ->
       match w.output with
       | None when not @@ List.is_empty wm.outputs ->
         Window.set_output w default;
         Option.iter (fun o -> Stacking.push [ w ] o) default
       | _ -> ())
    wm.windows
;;

let seat_sync ctx (seat : Seat.t) =
  (match seat.lifecycle with
   | Active -> refresh_layer_shell ctx seat
   | New | Closing -> ());
  Seat.refresh_cursor_target seat
;;

let apply_request ctx (seat : Seat.t) =
  let wm = Ctx.wm ctx in
  if wm.config.focus_follows_pointer && Option.is_none seat.op && seat.layer_focus = None
  then (
    match seat.focus_state with
    | Refresh w ->
      focus_window ~force:true ctx seat w;
      Seat.set_focus_state seat Idle
    | Clear ->
      clear ctx seat;
      Seat.set_focus_state seat Idle
    | Idle -> ())
;;

let apply_interaction ctx (seat : Seat.t) =
  match seat.interacted with
  | None -> ()
  | Some w ->
    focus_window ctx seat w;
    Seat.set_interacted seat None
;;

let apply_warp ctx (seat : Seat.t) =
  let warp =
    match seat.warp_request with
    | No_request -> false
    | Forced b -> b
    | Follow_config -> (Ctx.wm ctx).config.warp_on_focus
  in
  if warp then Pointer.warp_to_focus ctx seat;
  Seat.set_warp_request seat No_request
;;
