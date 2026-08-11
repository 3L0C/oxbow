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

let no_match kind to_string m =
  Error (Printf.sprintf "no %s matching %s" kind (to_string m))
;;

let matched_windows wm seat (wmatch : Window_match.t) =
  Result.bind (Window_pattern.compile wmatch.pattern)
  @@ fun matches ->
  Result.bind (Window_scope.filter wm seat wmatch.scope)
  @@ fun scoped ->
  let hits =
    windows_by_recency wm seat
    |> List.filter (fun w -> List.memq w scoped && Window_scope.holds matches w)
  in
  Ok (matches, scoped, hits)
;;

let matched_outputs wm seat (omatch : Output_match.t) =
  Result.bind (Output_match.compile omatch)
  @@ fun matches ->
  let hits =
    outputs_by_recency wm seat
    |> List.filter (fun (o : Output.t) -> matches ~name:o.name ~labels:o.labels)
  in
  Ok (matches, hits)
;;

let return_window_cycle seat matches scoped ~best =
  let stable = List.find_all (Window_scope.holds matches) scoped in
  let next =
    match Seat.focused_window seat with
    | Some w when List.memq w stable -> Ring.next_or_first w stable
    | _ -> List.nth_opt stable 0
  in
  Ok (Option.value next ~default:best)
;;

let return_output_cycle (seat : Seat.t) hits ~best =
  let next =
    match seat.output with
    | Some o when List.memq o hits -> Ring.next_or_first o hits
    | _ -> List.nth_opt hits 0
  in
  Ok (Option.value next ~default:best)
;;

let resolve_one_window wm seat (target : Target.Window.One.t) =
  match target with
  | Focused -> With.focused_window seat @@ fun _o w -> Ok w
  | Matching { wmatch; select } ->
    Result.bind (matched_windows wm seat wmatch)
    @@ fun (matches, scoped, hits) ->
    (match hits with
     | [] -> no_match "window" Window_match.to_string wmatch
     | best :: _ ->
       if select = Best then Ok best else return_window_cycle seat matches scoped ~best)
;;

let resolve_one_output wm seat (target : Target.Output.One.t) =
  match target with
  | Focused -> With.focused_output seat @@ fun o -> Ok o
  | Matching { omatch; select } ->
    Result.bind (matched_outputs wm seat omatch)
    @@ fun (_, hits) ->
    (match hits with
     | [] -> no_match "output" Output_match.to_string omatch
     | best :: _ -> if select = Best then Ok best else return_output_cycle seat hits ~best)
;;

let resolve_all_windows wm seat (target : Target.Window.Any.t) =
  match target with
  | One o -> Result.bind (resolve_one_window wm seat o) @@ fun w -> Ok [ w ]
  | All { wmatch } ->
    Result.bind (matched_windows wm seat wmatch)
    @@ fun (_, _, hits) ->
    (match hits with
     | [] -> no_match "window" Window_match.to_string wmatch
     | _ -> Ok hits)
;;

let resolve_all_outputs wm seat (target : Target.Output.Any.t) =
  match target with
  | One o -> Result.bind (resolve_one_output wm seat o) @@ fun o -> Ok [ o ]
  | All { omatch } ->
    Result.bind (matched_outputs wm seat omatch)
    @@ fun (_, hits) ->
    (match hits with
     | [] -> no_match "output" Output_match.to_string omatch
     | _ -> Ok hits)
;;

let transact windows plan =
  Result.bind
    (List.fold_left
       (fun acc w ->
          Result.bind acc
          @@ fun actions -> Result.bind (plan w) @@ fun action -> Ok (action :: actions))
       (Ok [])
       windows)
  @@ fun rev_actions ->
  (* The actions run reversed of the window order. This is depended on by
     [Stacking.push], which puts the first window on top. If the actions were in
     window order, the last window would be the head. *)
  List.iter (fun action -> action ()) rev_actions;
  Ok windows
;;

let transact_all_windows wm seat target ~plan =
  Result.bind (resolve_all_windows wm seat target) @@ fun windows -> transact windows plan
;;

let transact_all_outputs wm seat target ~plan =
  Result.bind (resolve_all_outputs wm seat target) @@ fun outputs -> transact outputs plan
;;

let transact_one_window wm seat target ~plan =
  Result.bind (resolve_one_window wm seat target)
  @@ fun window ->
  Result.bind (plan window)
  @@ fun action ->
  action ();
  Ok window
;;

let transact_one_output wm seat target ~plan =
  Result.bind (resolve_one_output wm seat target)
  @@ fun output ->
  Result.bind (plan output)
  @@ fun action ->
  action ();
  Ok output
;;
