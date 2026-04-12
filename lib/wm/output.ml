(* ocdwm output - output handlers *)
module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Utils = Ocdwm_core.Utils
open Ocdwm_core.Types
open Types

let destroy = Rwm.River_output_v1.destroy

let focus (target : window) = function
  | Some o ->
      o.focus_stack <-
        target
        :: List.filter (fun w -> w != target) o.focus_stack
  | None -> ()

let focused_window output =
  List.nth_opt output.focus_stack 0

let next_tiled : window list -> window option =
  Utils.wrapped_search Window.is_visible (fun w ->
    (Option.get w.output).windows)

let prev_tiled : window list -> window option =
  Utils.wrapped_search Window.is_visible (fun w ->
    (Option.get w.output).windows |> List.rev)

let next_window (output : output) =
  match focused_window output with
  | None -> None
  | Some f -> begin
      let rec after = function
        | w :: [] when w == f -> next_tiled output.windows
        | w :: xs when w == f -> next_tiled xs
        | _ :: xs -> after xs
        | [] ->
            failwith
              "Focused window isn't in output window list"
      in
      after output.windows
    end

let prev_window (output : output) =
  match focused_window output with
  | None -> None
  | Some f -> begin
      let rec after = function
        | w :: [] when w == f -> prev_tiled output.windows
        | w :: xs when w == f -> prev_tiled xs
        | _ :: xs -> after xs
        | [] ->
            failwith
              "Focused window isn't in output window list"
      in
      List.rev output.windows |> after
    end
