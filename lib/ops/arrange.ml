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

let set_arrangement (seat : Seat.t) (a : Arrangement.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    Output.set_arrangement o a;
    Ok None
;;

let retile ctx (output : Output.t) =
  match output.arrangement with
  | Overview _ -> Overview.arrange ctx output
  | Tiling -> Tiling.arrange ctx output
  | Scrolling -> Scrolling.arrange ctx output
;;
