(* ocdwm focus - handles focus logic accross seat/output *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

open Types
open Ocdwm_core.Types

let focused_of (seat : seat) : window option =
  match seat.output with
  | Some o -> Output.focused_window o
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
      Output.focus_window target;
      Rwm.River_seat_v1.focus_window seat.obj
        ~window:target.obj;
      Rwm.River_node_v1.place_top target.node
    end

let clear (seat : seat) =
  Rwm.River_seat_v1.clear_focus seat.obj

let refresh_focus (wm : window_manager) = function
  | None -> ()
  | Some (o : output) ->
      begin match Output.focused_window o with
      | None -> begin
          wm.focused_output <- Some o;
          List.iter
            (fun s ->
               match s.output with
               | Some so when so == o -> clear s
               | _ -> ())
            wm.seats
        end
      | Some w -> begin
          wm.focused_output <- Some o;
          List.iter
            (fun s ->
               match s.output with
               | Some so when so == o -> begin
                   Rwm.River_seat_v1.focus_window s.obj
                     ~window:w.obj;
                   Rwm.River_node_v1.place_top w.node
                 end
               | _ -> ())
            wm.seats
        end
      end

let focus_dir
      (wm : window_manager)
      (seat : seat)
      (dir : direction)
  =
  match (focused_of seat, seat.output) with
  | Some w, _ when Window.is_fullscreen w -> ()
  | _, None -> ()
  | _, Some o ->
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

let remove_window (wm : window_manager) (window : window) =
  Output.remove_window window;
  refresh_focus wm window.output
