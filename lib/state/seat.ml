open! Oxbow_core
open! Oxbow_ipc
include Types.Seat

module Warp_request = struct
  include Types.Seat.Warp_request

  let of_override = function
    | Some b -> Forced b
    | None -> Follow_config
  ;;
end

let unbind_xkb_binding s mode mods keysym =
  let matches (b : Xkb_binding.t) =
    String.equal b.mode mode && b.mods = mods && b.keysym = keysym
  in
  let to_destroy, to_keep = List.partition matches s.xkb_bindings in
  List.iter (fun (k : Xkb_binding.t) -> Emit.destroy_xkb_binding k.obj) to_destroy;
  s.xkb_bindings <- to_keep;
  not @@ List.is_empty to_destroy
;;

let queue_pending s request =
  Queue.add request s.pending_requests;
  Schedule.manage ()
;;

let xkb_binding_create (wm : Types.Wm.t) s mode mods keysym command =
  let body = Request.Body.Command command in
  let keysym_i32 = Int32.of_int (Xkbcommon.Keysym.to_int keysym) in
  let binding : Xkb_binding.t =
    { obj =
        Emit.create_xkb_binding
          wm.river_xkb_v1
          ~seat:s.obj
          ~keysym:keysym_i32
          ~mods
          ~on_pressed:(fun () -> queue_pending s { body; reply = None })
    ; seat = s
    ; mode
    ; enabled = false
    ; command
    ; mods
    ; keysym
    }
  in
  s.xkb_bindings <- binding :: s.xkb_bindings
;;

let replace_xkb_binding wm s mode mods keysym command =
  let replaced = unbind_xkb_binding s mode mods keysym in
  xkb_binding_create wm s mode mods keysym command;
  replaced
;;

let unbind_pointer_binding s mode mods button =
  let matches (p : Pointer_binding.t) =
    String.equal p.mode mode && p.mods = mods && p.button = button
  in
  let to_destroy, to_keep = List.partition matches s.pointer_bindings in
  List.iter (fun (p : Pointer_binding.t) -> Emit.destroy_pointer_binding p.obj) to_destroy;
  s.pointer_bindings <- to_keep;
  not @@ List.is_empty to_destroy
;;

let pointer_binding_create s mode mods button command =
  let body = Request.Body.Command command in
  let binding : Pointer_binding.t =
    { obj =
        Emit.create_pointer_binding
          s.obj
          ~button:(Pointer_button.to_int32 button)
          ~mods
          ~on_pressed:(fun () -> queue_pending s { body; reply = None })
    ; seat = s
    ; mode
    ; enabled = false
    ; command
    ; mods
    ; button
    }
  in
  s.pointer_bindings <- binding :: s.pointer_bindings
;;

let replace_pointer_binding s mode mods button command =
  let replaced = unbind_pointer_binding s mode mods button in
  pointer_binding_create s mode mods button command;
  replaced
;;

let refresh_cursor_target s =
  if Option.is_some s.hovered then s.cursor_target <- s.hovered
;;

let drain_pending s = Queue.take_opt s.pending_requests

let clear_pending s =
  Queue.iter
    (fun (p : Pending_request.t) ->
       Option.iter (fun u -> Eio.Promise.resolve_error u "wm shutting down") p.reply)
    s.pending_requests;
  Queue.clear s.pending_requests
;;

let set_output s output =
  match s.output, output with
  | Some o, Some o' when o == o' -> ()
  | None, None -> ()
  | _ ->
    s.output <- output;
    Schedule.manage ()
;;

let set_focus_cleared s v = s.focus_cleared <- v

let focus_output s output =
  if not @@ Phys.opt_equal s.output output then set_output s output
;;

let set_layer_focus s layer =
  s.layer_focus <- layer;
  Schedule.manage ()
;;

let set_mode (wm : Types.Wm.t) s mode =
  if not @@ List.mem mode wm.config.modes
  then Error (Printf.sprintf "mode not declared: %S" mode)
  else if String.equal mode Mode.locked
  then Error "cannot enter 'locked' mode manually"
  else Ok (s.mode <- mode)
;;

let set_position s (x, y) = s.position <- { x; y }

let set_cursor_target s window =
  s.cursor_target <- window;
  Schedule.manage ()
;;

let set_focus_state s state = s.focus_state <- state
let set_op s op = s.op <- Some op
let clear_op s = s.op <- None

let set_op_delta s dx dy =
  match s.op with
  | Some (Move d) ->
    d.dx <- dx;
    d.dy <- dy
  | Some (Resize d) ->
    d.dx <- dx;
    d.dy <- dy
  | None -> ()
;;

let release_op s =
  match s.op with
  | Some (Move d) -> d.release <- true
  | Some (Resize d) -> d.release <- true
  | None -> ()
;;

let set_lifecycle s lifecycle = s.lifecycle <- lifecycle
let set_name s name = s.name <- name
let set_hovered s window = s.hovered <- window
let set_interacted s window = s.interacted <- window
let set_warp_request s v = s.warp_request <- v
let set_overview_watch s v = s.overview_watch <- v
let set_watch_sent s sent = s.watch_sent <- sent

let bind (wm : Types.Wm.t) s ?(mode = Mode.normal) mods (key : Types.Key.t) command =
  if not @@ List.mem mode wm.config.modes
  then Error (Printf.sprintf "mode not declared: %S" mode)
  else
    Ok
      (match key with
       | Keysym keysym -> replace_xkb_binding wm s mode mods keysym command
       | Pointer button -> replace_pointer_binding s mode mods button command)
;;

let unbind (wm : Types.Wm.t) s ?(mode = Mode.normal) mods (key : Types.Key.t) =
  if not @@ List.mem mode wm.config.modes
  then Error (Printf.sprintf "mode not declared: %S" mode)
  else
    Ok
      (match key with
       | Keysym keysym -> unbind_xkb_binding s mode mods keysym
       | Pointer button -> unbind_pointer_binding s mode mods button)
;;

let focused_window s =
  match s.output with
  | Some o -> Output.focused_window o
  | None -> None
;;
