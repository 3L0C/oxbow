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

let focus_window ?(force : bool = false) ~warp ctx (seat : Seat.t) (target : Window.t) =
  let force = force || Option.is_some seat.layer_focus in
  match Seat.focused_window seat with
  | Some w when w == target && not force -> ()
  | _ ->
    set_output ctx seat target.output;
    Stacking.focus_window ctx seat target;
    (* FIXME need to delay this because zoom forces a retile which changes the
       warp location *)
    if warp then Pointer.warp_to_focus ctx seat
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
          | Some w -> focus_window ~force:true ~warp:false ctx s w
          | None -> clear ctx s)
       | _ -> ())
    wm.seats
;;

let refresh_layer_shell ctx (seat : Seat.t) =
  if Option.is_none seat.layer_focus
  then (
    match Seat.focused_window seat with
    | Some w -> focus_window ~force:true ~warp:false ctx seat w
    | None -> clear ctx seat)
;;

let window_logical ctx seat (dir : Direction.Logical.t) =
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
       focus_window ~warp:true ctx seat w;
       Ok None)
;;

let window_spatial ctx seat (dir : Direction.Spatial.t) =
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
       focus_window ~warp:true ctx seat w;
       Ok None)
;;

let window_query ~cycle ctx seat q =
  let wm = Ctx.wm ctx in
  match Window_query.compile q with
  | Error e -> Error e
  | Ok matches ->
    let windows =
      List.find_all
        (fun (w : Window.t) ->
           matches ~title:w.title ~app_id:w.app_id ~identifier:w.identifier)
        wm.windows
    in
    let target =
      match Seat.focused_window seat with
      | Some w
        when cycle && matches ~title:w.title ~app_id:w.app_id ~identifier:w.identifier ->
        Ring.next_or_first w windows
      | _ -> List.nth_opt windows 0
    in
    (match target with
     | None ->
       Error (Printf.sprintf "no window matches query: %S" (Window_query.to_string q))
     | Some w ->
       focus_window ~force:true ~warp:true ctx seat w;
       Ok None)
;;

let focus_output ~warp ctx seat output =
  set_output ctx seat @@ Some output;
  Pointer.warp_to_focus ctx seat;
  match Output.focused_window output with
  | Some w -> focus_window ~warp ctx seat w
  | None -> clear ctx seat
;;

let output_logical ctx (seat : Seat.t) (dir : Direction.Logical.t) =
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
       focus_output ~warp:true ctx seat t;
       Ok None
     | _ -> Error Messages.no_other_output)
;;

let output_spatial ctx (seat : Seat.t) (dir : Direction.Spatial.t) =
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
       focus_output ~warp:true ctx seat o;
       Ok None)
;;

let output_name ctx (seat : Seat.t) (name : string) =
  let wm = Ctx.wm ctx in
  match
    List.find_opt
      (fun (o : Output.t) -> Option.fold ~none:false ~some:(fun n -> n = name) o.name)
      wm.outputs
  with
  | None -> Error (Printf.sprintf "no output named %S" name)
  | Some o ->
    (match seat.output with
     | None -> focus_output ~warp:true ctx seat o
     | Some o' when o != o' -> focus_output ~warp:true ctx seat o
     | _ -> ());
    Ok None
;;

let remove_window ctx window =
  Option.iter (Stacking.remove_window ~window) window.output;
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
   | Dirty { prev = Closing } -> Seat.set_lifecycle seat Closing
   | Dirty { prev } ->
     (* The dirty flag is taken before handling: a handler that re-marks this
        output schedules another cycle, so handlers must be idempotent. *)
     Seat.set_lifecycle seat prev;
     refresh_layer_shell ctx seat;
     if Seat.is_dirty seat
     then
       Logs.debug
       @@ fun m ->
       m
         "seat_sync: %s re-dirtied during its own handling (non-idempotent handler?)"
         (Option.value seat.name ~default:"<unnamed>")
   | New | Active | Closing -> ());
  Seat.refresh_cursor_target seat
;;

let apply_request ctx (seat : Seat.t) =
  let wm = Ctx.wm ctx in
  if wm.config.focus_follows_pointer && Option.is_none seat.op && seat.layer_focus = None
  then (
    match seat.focus_state with
    | Refresh w ->
      focus_window ~force:true ~warp:false ctx seat w;
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
    focus_window ~warp:false ctx seat w;
    Seat.set_interacted seat None
;;
