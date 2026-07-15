let notify = ref (fun () -> ())
let deferring = ref false
let send () = if !deferring then () else !notify ()
let install c = notify := c

let mark_seat (seat : Types.Seat.t) =
  match seat.lifecycle with
  | Dirty _ -> ()
  | prev ->
    seat.lifecycle <- Dirty { prev };
    send ()
;;

let mark_output (output : Types.Output.t) =
  match output.lifecycle with
  | Dirty _ -> ()
  | prev ->
    output.lifecycle <- Dirty { prev };
    send ()
;;

let mark_wm (wm : Types.Wm.t) =
  if not wm.is_dirty
  then (
    wm.is_dirty <- true;
    send ())
;;

let mark_all (wm : Types.Wm.t) =
  mark_wm wm;
  List.iter mark_output wm.outputs;
  List.iter mark_seat wm.seats
;;

let with_deferred (wm : Types.Wm.t) f =
  let output_is_dirty (o : Types.Output.t) =
    match o.lifecycle with
    | Dirty _ -> true
    | _ -> false
  in
  let seat_is_dirty (s : Types.Seat.t) =
    match s.lifecycle with
    | Dirty _ -> true
    | _ -> false
  in
  assert (not !deferring);
  deferring := true;
  Fun.protect f ~finally:(fun () ->
    deferring := false;
    if
      wm.is_dirty
      || List.exists output_is_dirty wm.outputs
      || List.exists seat_is_dirty wm.seats
    then !notify ())
;;
