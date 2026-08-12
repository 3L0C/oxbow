open! Oxbow_core
open! Oxbow_state
open! Result.Syntax

let layer_shell_sync (wm : Wm.t) =
  match Wm.focused_output wm with
  | None -> ()
  | Some o -> Emit.set_default o.layer_shell
;;

let set_output (wm : Wm.t) seat output =
  Seat.set_output seat output;
  if Phys.opt_holds seat wm.primary_seat then layer_shell_sync wm
;;

let focus_window ?(force : bool = false) ?warp wm (seat : Seat.t) (target : Window.t) =
  let force = force || Option.is_some seat.layer_focus in
  match Seat.focused_window seat with
  | Some w when w == target && not force -> ()
  | _ ->
    set_output wm seat target.output;
    Seat.set_focus_cleared seat false;
    Stacking.focus_window target;
    Option.iter (Seat.set_warp_request seat) warp
;;

let refresh (wm : Wm.t) output =
  let target = Output.focused_window output in
  List.iter
    (fun (s : Seat.t) ->
       match s.output with
       | Some o when o == output ->
         (match target with
          | Some w -> focus_window ~force:true wm s w
          | None -> ())
       | _ -> ())
    wm.seats
;;

let refresh_layer_shell wm (seat : Seat.t) =
  if Option.is_none seat.layer_focus
  then (
    match Seat.focused_window seat with
    | Some w -> focus_window ~force:true wm seat w
    | None -> ())
;;

let window_logical ?warp wm seat target (dir : Direction.Logical.t) =
  let+ _ =
    Targets.transact_one_window wm seat target ~plan:(fun w ->
      if Window.is_fullscreen w
      then Error Messages.window_is_fullscreen
      else (
        match w.output with
        | None -> Error Messages.seat_missing_output
        | Some o ->
          let target =
            match dir with
            | Next -> Output.next_window o
            | Prev -> Output.prev_window o
          in
          (match target with
           | None -> Error "no window to focus"
           | Some w ->
             Ok
               (fun () ->
                 focus_window ~warp:(Seat.Warp_request.of_override warp) wm seat w))))
  in
  None
;;

let window_spatial ?warp wm seat target (dir : Direction.Spatial.t) =
  let+ _ =
    Targets.transact_one_window wm seat target ~plan:(fun current ->
      if Window.is_fullscreen current
      then Error Messages.window_is_fullscreen
      else (
        match current.output with
        | None -> Error Messages.seat_missing_output
        | Some o ->
          let from = Vector.center (Rect.to_int current.geom) in
          let target =
            Vector.nearest_in_direction
              ~from
              ~dir
              (fun w ->
                 if
                   w == current
                   || (not @@ Window.is_tiled w)
                   || (not @@ Window.tag_visible w)
                 then None
                 else Some (Rect.to_int w.geom |> Vector.center))
              o.wm_stack
          in
          (match target with
           | None ->
             Error (Printf.sprintf "no window %s" (Direction.Spatial.to_string dir))
           | Some w ->
             Ok
               (fun () ->
                 focus_window ~warp:(Seat.Warp_request.of_override warp) wm seat w))))
  in
  None
;;

let window_match ?warp wm seat target =
  let+ window = Targets.resolve_one_window wm seat target in
  focus_window ~force:true ~warp:(Seat.Warp_request.of_override warp) wm seat window;
  None
;;

let focus_output ?warp wm seat output =
  set_output wm seat @@ Some output;
  Seat.(Warp_request.of_override warp |> set_warp_request seat);
  match Output.focused_window output with
  | Some w -> focus_window wm seat w
  | None -> ()
;;

let output_match ?warp wm seat target =
  let+ output = Targets.resolve_one_output wm seat target in
  focus_output ?warp wm seat output;
  None
;;

let output_logical ?warp (wm : Wm.t) (seat : Seat.t) (dir : Direction.Logical.t) =
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
       focus_output ?warp wm seat t;
       Ok None
     | _ -> Error Messages.no_other_output)
;;

let output_spatial ?warp (wm : Wm.t) (seat : Seat.t) (dir : Direction.Spatial.t) =
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
       focus_output ?warp wm seat o;
       Ok None)
;;

let focus_parent (child : Window.t) =
  match child.parent with
  | Some ({ lifecycle = New | Active; _ } as p) ->
    With.output_log child @@ fun o -> Stacking.restore_focus_order ~like:[ p ] o
  | _ -> ()
;;

let remove_window wm (window : Window.t) =
  let was_focused =
    match window.output with
    | Some o -> Phys.opt_holds window (Output.focused_window o)
    | None -> false
  in
  Option.iter (Stacking.remove_window ~window) window.output;
  if was_focused then focus_parent window;
  Option.iter (refresh wm) window.output
;;

let wm_sync (wm : Wm.t) =
  let default = Wm.default_output wm in
  List.iter
    (fun (s : Seat.t) ->
       match s.output with
       | Some o when not @@ List.memq o wm.outputs -> set_output wm s default
       | None when not @@ List.is_empty wm.outputs -> set_output wm s default
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

let seat_sync wm (seat : Seat.t) =
  (match seat.lifecycle with
   | Active -> refresh_layer_shell wm seat
   | New | Closing -> ());
  Seat.refresh_cursor_target seat
;;

let apply_request (wm : Wm.t) (seat : Seat.t) =
  if
    wm.config.focus_follows_pointer <> Never
    && Option.is_none seat.op
    && seat.layer_focus = None
  then (
    match seat.focus_state with
    | Refresh w ->
      focus_window ~force:true wm seat w;
      Seat.set_focus_state seat Idle
    | Clear ->
      Seat.set_focus_cleared seat true;
      Seat.set_focus_state seat Idle
    | Idle -> ())
;;

let apply_interaction wm (seat : Seat.t) =
  match seat.interacted with
  | None -> ()
  | Some w ->
    focus_window wm seat w;
    Seat.set_interacted seat None
;;
