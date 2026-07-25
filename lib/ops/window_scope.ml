open! Ocdwm_core
open! Ocdwm_state

let filter (wm : Wm.t) (seat : Seat.t) (scope : Window_match.Scope.t) =
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
