open! Oxbow_core
open! Oxbow_state

let config wm ~all =
  Config.reset wm ~all;
  if all
  then
    List.iter
      (fun s ->
         Seat.clear_bindings s;
         Result.iter_error (fun msg -> Log.err @@ fun m -> m "%s" msg)
         @@ Seat.set_mode s Mode.normal;
         Bind.install_defaults wm s)
      wm.seats;
  Schedule.manage ();
  Ok None
;;
