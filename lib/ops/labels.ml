open! Oxbow_state

let apply transact action wm seat target label =
  Result.map (fun _ -> None)
  @@ transact wm seat target ~plan:(fun x -> Ok (fun () -> action x label))
;;

let window_add = apply Targets.transact_all_windows Window.add_label
let window_remove = apply Targets.transact_all_windows Window.remove_label
let output_add = apply Targets.transact_all_outputs Output.add_label
let output_remove = apply Targets.transact_all_outputs Output.remove_label
