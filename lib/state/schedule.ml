let send = ref (fun () -> ())
let requested = ref false
let in_tick = ref false
let install f = send := f

let manage () =
  if not !requested
  then (
    requested := true;
    if not !in_tick then !send ())
;;

let with_tick f =
  assert (not !in_tick);
  requested := false;
  in_tick := true;
  Fun.protect f ~finally:(fun () -> if !requested then !send ())
;;
