(* ocdwm window manager - state management *)
[@@@landmark "auto"]

include Types.Window_manager_t
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
open Types

let set_focused_output (wm : t) (output : Output_t.t option) =
  wm.focused_output <- output;
  wm.dirty <- true
;;

let refresh_layer_shell_output (wm : t) =
  match wm.focused_output with
  | None -> ()
  | Some o -> Rlsh.River_layer_shell_output_v1.set_default o.layer_shell
;;

let focus_output (ctx : Ctx.manage Ctx.t) (output : Types.Output_t.t option) =
  let wm = Ctx.wm ctx in
  wm.focused_output <- output;
  refresh_layer_shell_output wm
;;

let sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  if wm.dirty
  then (
    refresh_layer_shell_output wm;
    wm.dirty <- false)
;;
