open! Oxbow_state

let set wm seat target name =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    Ok (fun () -> Window.set_scratchpad w name))
;;

let clear wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    Ok
      (fun () ->
        Window.set_scratchpad w None;
        Window.set_stashed w false))
;;

let toggle (wm : Wm.t) (seat : Seat.t) name =
  let members =
    List.filter (fun (w : Window.t) -> w.scratchpad.name = Some name) wm.windows
  in
  let shown = List.exists Window.tag_visible members in
  With.focused_output seat
  @@ fun o ->
  match members with
  | [] -> Error (Printf.sprintf "no scratchpad named %S" name)
  | _ when shown ->
    List.iter (fun w -> Window.set_stashed w true) members;
    Schedule.manage ();
    Ok None
  | head :: _ ->
    List.iter
      (fun w ->
         Window.set_stashed w false;
         Placement.move_window w o ~policy:Take;
         Window.float w)
      members;
    Focus.focus_window wm seat head;
    Schedule.manage ();
    Ok None
;;
