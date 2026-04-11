(* ocdwm output - output handlers *)
module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

open Types

let destroy = Rwm.River_output_v1.destroy

let focus (target : window) = function
  | Some o ->
      o.focus_stack <-
        target
        :: List.filter (fun w -> w != target) o.focus_stack
  | None -> ()
