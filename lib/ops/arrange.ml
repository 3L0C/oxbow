open! Ocdwm_core
open! Ocdwm_layout
open! Ocdwm_state

let set_mfact (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_mfact o delta;
    Ok None
;;

let set_nmaster (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_nmaster o delta;
    Ok None
;;

let set_gaps_inner (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_gaps_inner o delta;
    Ok None
;;

let set_gaps_outer (seat : Seat.t) delta =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_gaps_outer o delta;
    Ok None
;;

let set_stack (seat : Seat.t) kind =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_stack o kind;
    Ok None
;;

let set_dir (seat : Seat.t) dir =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_dir o dir;
    Ok None
;;

let enter_overview ctx (output : Output.t) =
  let aux prev =
    List.iter (fun w -> Window_request.handle ctx w Exit_fullscreen) output.wm_stack;
    Output.set_arrangement output (Overview prev)
  in
  match output.arrangement with
  | Overview _ -> ()
  | Tiling -> aux `Tiling
  | Scrolling -> aux `Scrolling
;;

let exit_overview ctx (output : Output.t) =
  match output.arrangement with
  | Tiling | Scrolling -> ()
  | Overview prev ->
    let focused = Output.focused_window output in
    (match prev with
     | `Tiling -> Output.set_arrangement output Tiling
     | `Scrolling -> Output.set_arrangement output Scrolling);
    (match focused with
     | Some w -> Output.switch_tags ~tags:w.tags output
     | None -> ());
    List.iter
      (fun (w : Window.t) ->
         match w.presentation with
         | Fullscreen _ | Tiled -> ()
         | Floating -> Window.restore_or_seed_float ctx w
         | Maximized { restore } -> Window.maximize ~restore ctx w)
      output.wm_stack;
    Dirty.mark_output output
;;

let toggle_overview ctx (seat : Seat.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    (match o.arrangement with
     | Tiling | Scrolling ->
       enter_overview ctx o;
       Ok None
     | Overview _ ->
       exit_overview ctx o;
       Ok None)
;;

let set_arrangement ctx (seat : Seat.t) (a : Arrangement.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    let no_op =
      match o.arrangement, a with
      | Overview _, Overview _ | Tiling, Tiling | Scrolling, Scrolling -> true
      | _ -> false
    in
    if no_op
    then Ok None
    else (
      match a with
      | Overview _ ->
        enter_overview ctx o;
        Ok None
      | Tiling | Scrolling ->
        (match o.arrangement with
         | Overview prev ->
           exit_overview ctx o;
           Ok None
         | Tiling | Scrolling ->
           Output.set_arrangement o a;
           Ok None))
;;

let retile ctx (output : Output.t) =
  match output.arrangement with
  | Overview _ -> Overview.arrange ctx output
  | Tiling -> Tiling.arrange ctx output
  | Scrolling -> Scrolling.arrange ctx output
;;
