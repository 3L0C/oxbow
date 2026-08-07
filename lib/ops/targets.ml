open! Oxbow_core
open! Oxbow_state

let outputs_by_recency (wm : Wm.t) (seat : Seat.t) =
  match seat.output with
  | None -> wm.outputs
  | Some o -> o :: List.filter (( != ) o) wm.outputs
;;

let windows_by_recency wm seat =
  let stacks = outputs_by_recency wm seat in
  let ordered = List.(map (fun (o : Output.t) -> o.focus_stack) stacks |> flatten) in
  let orphans = List.filter (fun (w : Window.t) -> Option.is_none w.output) wm.windows in
  ordered @ orphans
;;

let resolve_windows wm seat (target : Target.Window.t) f =
  match target with
  | Focused -> With.focused_window seat @@ fun _o w -> Ok [ w ]
  | Matching { wmatch; select } ->
    (match Window_match.compile wmatch with
     | Error _ as e -> e
     | Ok matches ->
       (match Window_scope.filter wm seat wmatch.scope with
        | Error _ as e -> e
        | Ok scoped ->
          let hits =
            windows_by_recency wm seat
            |> List.filter (fun w -> List.memq w scoped && Window_scope.holds matches w)
          in
          f ~wmatch ~select ~matches ~scoped ~hits ()))
;;

let return_best wmatch = function
  | [] -> Error (Printf.sprintf "no window matching %s" (Window_match.to_string wmatch))
  | best :: _ -> Ok [ best ]
;;

let return_cycle seat wmatch matches scoped = function
  | [] -> Error (Printf.sprintf "no window matching %s" (Window_match.to_string wmatch))
  | hits ->
    let focused = Seat.focused_window seat in
    let stable = List.find_all (Window_scope.holds matches) scoped in
    let next =
      match focused with
      | Some w when List.memq w stable -> Ring.next_or_first w stable
      | _ -> List.nth_opt stable 0
    in
    (match next with
     | Some w -> Ok [ w ]
     | None -> return_best wmatch hits)
;;

let resolve_all_windows wm seat target =
  resolve_windows wm seat target
  @@ fun ~wmatch ~select ~matches ~scoped ~hits () ->
  match select with
  | All -> Ok hits
  | Best -> return_best wmatch hits
  | Cycle -> return_cycle seat wmatch matches scoped hits
;;

let resolve_one_window wm seat target =
  Result.bind
    (resolve_windows wm seat target
     @@ fun ~wmatch ~select ~matches ~scoped ~hits () ->
     match select with
     | All -> Error "unable to operate on all windows"
     | Best -> return_best wmatch hits
     | Cycle -> return_cycle seat wmatch matches scoped hits)
    (function
      | [ window ] -> Ok window
      | _ -> Error "got more than one window")
;;

let transact_windows windows plan =
  let actions =
    List.fold_left
      (fun acc w ->
         match acc with
         | Error _ as e -> e
         | Ok l ->
           (match plan w with
            | Error _ as e -> e
            | Ok act -> Ok (act :: l)))
      (Ok [])
      windows
  in
  match actions with
  | Error _ as e -> e
  | Ok acts ->
    List.iter (fun act -> act ()) acts;
    Ok windows
;;

let transact_all_windows wm seat target ~plan =
  match resolve_all_windows wm seat target with
  | Error _ as e -> e
  | Ok windows -> transact_windows windows plan
;;

let transact_one_window wm seat target ~plan =
  Result.bind (resolve_one_window wm seat target) (fun window ->
    Result.bind (transact_windows [ window ] plan) (function
      | [ w ] -> Ok w
      | _ -> Error "got more than one window"))
;;
