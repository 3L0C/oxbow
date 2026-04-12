(* ocdwm focus - handles focus logic accross seat/output *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

open Types
open Ocdwm_core.Types

let focused_of (seat : seat) : window option =
  match seat.output with
  | Some o -> List.find_opt Window.is_visible o.focus_stack
  | None -> None

let focus_window
      (wm : window_manager)
      (seat : seat)
      (target : window)
  =
  match focused_of seat with
  | Some w when w == target -> ()
  | _ -> begin
      seat.output <- target.output;
      wm.focused_output <- target.output;
      Output.focus seat.output target;
      Rwm.River_seat_v1.focus_window seat.obj
        ~window:target.obj;
      Rwm.River_node_v1.place_top target.node
    end

let refresh_focus (output : output) (seats : seat list) = ()

let focus_dir
      (wm : window_manager)
      (seat : seat)
      (dir : direction)
  =
  match seat.output with
  | None -> ()
  | Some o ->
      begin match dir with
      | Dir_next ->
          Output.next_window o
          |> Option.iter (focus_window wm seat)
      | Dir_prev ->
          Output.prev_window o
          |> Option.iter (focus_window wm seat)
      | _ -> ()
      end

let focus_output (seat : seat) (dir : direction) = ()

let clear (seat : seat) =
  Rwm.River_seat_v1.clear_focus seat.obj

let get_output (lst : output list) = List.nth_opt lst 0

let focus_other_output
      (wm : window_manager)
      (output : output)
  =
  match wm.focused_output with
  | Some o when o == output ->
      wm.focused_output <-
        List.find_opt (fun o -> o != output) wm.outputs
  | _ -> ()
