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

let mark_dirty (wm : t) =
  wm.dirty <- true;
  Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let request_shutdown ?(origin = `Local) (wm : t) =
  let open Window_manager_state in
  match wm.state with
  | Wm_running ->
    wm.state <- Wm_pending_exit origin;
    mark_dirty wm
  | Wm_pending_close -> Rwm.River_window_manager_v1.stop wm.river_wm_v1
  | Wm_pending_exit _ ->
    wm.state <- Wm_exited;
    Rwm.River_window_manager_v1.exit_session wm.river_wm_v1;
    Eio.Condition.broadcast wm.shutdown
  | Wm_closed -> Eio.Condition.broadcast wm.shutdown
  | Wm_exited ->
    Logs.err
    @@ fun m -> m "got shutdown request when wayland session should have exited..."
;;

let await_shutdown (wm : t) =
  Eio.Condition.loop_no_mutex wm.shutdown (fun () ->
    let open Window_manager_state in
    match wm.state with
    | Wm_closed | Wm_exited -> Some ()
    | Wm_pending_close -> None
    | Wm_pending_exit _ -> None
    | Wm_running -> None)
;;
