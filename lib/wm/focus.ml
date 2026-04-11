(* ocdwm focus - handles focus logic accross seat/output *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

open Types
open Ocdwm_core.Types

let focused_of (seat : seat) : window option =
  match seat.output with
  | Some o -> List.find_opt Window.is_visible o.focus_stack
  | None -> None

let focus_window (seat : seat) (target : window) =
  match focused_of seat with
  | Some w when w == target -> ()
  | _ -> begin
      seat.output <- target.output;
      Output.focus target seat.output;
      Rwm.River_seat_v1.focus_window seat.obj
        ~window:target.obj;
      Rwm.River_node_v1.place_top target.node
    end

let refresh_focus (output : output) (seats : seat list) = ()
let focus_dir (seat : seat) (dir : direction) = ()
let focus_output (seat : seat) (dir : direction) = ()

let clear (seat : seat) =
  Rwm.River_seat_v1.clear_focus seat.obj

let get_output = function
  | o :: _ -> Some o
  | [] -> None
