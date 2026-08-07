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

let resolve_windows wm seat (target : Target.Window.t) =
  match target with
  | Focused -> With.focused_window seat @@ fun _o w -> Ok [ w ]
  | Matching { wmatch; all } ->
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
          (match hits, all with
           | [], _ ->
             Error
               (Printf.sprintf "no window matching %s" (Window_match.to_string wmatch))
           | best :: _, false -> Ok [ best ]
           | hits, true -> Ok hits)))
;;

let transact_windows wm seat target ~plan =
  match resolve_windows wm seat target with
  | Error _ as e -> e
  | Ok windows ->
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
    (match actions with
     | Error _ as e -> e
     | Ok acts ->
       List.iter (fun act -> act ()) acts;
       Ok windows)
;;
