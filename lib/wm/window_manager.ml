module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client

type t = Types.Window_manager.t

let set_focused_output (wm : t) (output : Types.Output.t option) =
  wm.focused_output <- output;
  wm.dirty <- true;
  Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let refresh_layer_shell_output (wm : t) =
  match wm.focused_output with
  | None -> ()
  | Some o -> Rlsh.River_layer_shell_output_v1.set_default o.layer_shell
;;

let focus_output (ctx : Ctx.manage Ctx.t) (output : Types.Output.t option) =
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

let request_shutdown ?(origin = `Local) (wm : t) =
  (match !(wm.shutdown_origin) with
   | None -> wm.shutdown_origin := Some origin
   | Some _ -> ());
  Eio.Condition.broadcast wm.shutdown
;;

let await_shutdown (wm : t) =
  Eio.Condition.loop_no_mutex wm.shutdown (fun () ->
    match !(wm.shutdown_origin) with
    | Some _ -> Some ()
    | None -> None)
;;
