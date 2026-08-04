open! Oxbow_core
open! Oxbow_state

let filter (wm : Wm.t) (seat : Seat.t) (scope : Scope.t) =
  let on_output o =
    List.filter (fun (w : Window.t) -> Phys.opt_holds o w.output) wm.windows
  in
  match scope with
  | All -> Ok wm.windows
  | Focused -> With.focused_output seat @@ fun o -> Ok (on_output o)
  | Output name ->
    (match List.find_opt (Output.matches_name name) wm.outputs with
     | None -> Error (Printf.sprintf "unknown output: %s" name)
     | Some o -> Ok (on_output o))
;;

let holds matches (w : Window.t) =
  matches ~title:w.title ~app_id:w.app_id ~identifier:w.identifier
;;

let matching wm seat (m : Window_match.t) =
  match Window_match.compile m with
  | Error _ as e -> e
  | Ok matches ->
    (match filter wm seat m.scope with
     | Error _ as e -> e
     | Ok windows -> Ok (holds matches, List.find_all (holds matches) windows))
;;
