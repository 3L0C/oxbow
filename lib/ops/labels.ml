open! Oxbow_state

let window_add wm seat target label =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    Ok (fun () -> Window.add_label w label))
;;

let window_remove wm seat target label =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    Ok (fun () -> Window.remove_label w label))
;;

let output_add seat label =
  With.focused_output seat
  @@ fun o ->
  Output.add_label o label;
  Ok None
;;

let output_remove seat label =
  With.focused_output seat
  @@ fun o ->
  Output.remove_label o label;
  Ok None
;;
