open! Ocdwm_core
open! Ocdwm_ipc
include Types.Seat

module Warp_request = struct
  include Types.Seat.Warp_request

  let of_override = function
    | Some b -> Forced b
    | None -> Follow_config
  ;;
end

let effective_mode ctx (seat : t) =
  if (Ctx.wm ctx).session_locked then Mode.locked else seat.mode
;;

let xkb_binding_destroy (_ : Ctx.manage Ctx.t) (binding : Xkb_binding.t) =
  River.Xkb_bindings.River_xkb_binding_v1.destroy binding.obj
;;

let unbind_xkb_binding ctx (seat : t) mode mods keysym =
  let matches (b : Xkb_binding.t) =
    String.equal b.mode mode && b.mods = mods && b.keysym = keysym
  in
  let to_destroy, to_keep = List.partition matches seat.xkb_bindings in
  List.iter (xkb_binding_destroy ctx) to_destroy;
  seat.xkb_bindings <- to_keep;
  not @@ List.is_empty to_destroy
;;

let xkb_binding_create (ctx : Ctx.manage Ctx.t) seat mode mods keysym command =
  let wm = Ctx.wm ctx in
  let body = Request.Body.Command command in
  let keysym_i32 = Int32.of_int (Xkbcommon.Keysym.to_int keysym) in
  let binding : Xkb_binding.t =
    { obj =
        River.Xkb_bindings.River_xkb_bindings_v1.get_xkb_binding
          wm.river_xkb_v1
          ~seat:seat.obj
          object
            inherit [_] River.Xkb_bindings.River_xkb_binding_v1.v2
            method on_stop_repeat _ = ()
            method on_released _ = ()

            method on_pressed _ =
              Queue.push Pending_request.{ body; reply = None } seat.pending_requests
          end
          ~keysym:keysym_i32
          ~modifiers:mods
    ; seat
    ; mode
    ; enabled = String.equal mode (effective_mode ctx seat)
    ; command
    ; mods
    ; keysym
    }
  in
  River.Xkb_bindings.River_xkb_binding_v1.enable binding.obj;
  seat.xkb_bindings <- binding :: seat.xkb_bindings
;;

let replace_xkb_binding ctx seat mode mods keysym command =
  let replaced = unbind_xkb_binding ctx seat mode mods keysym in
  xkb_binding_create ctx seat mode mods keysym command;
  replaced
;;

let pointer_binding_destroy (_ : Ctx.manage Ctx.t) (pointer : Pointer_binding.t) =
  River.Window_management.River_pointer_binding_v1.destroy pointer.obj
;;

let unbind_pointer_binding ctx (seat : t) mode mods button =
  let matches (p : Pointer_binding.t) =
    String.equal p.mode mode && p.mods = mods && p.button = button
  in
  let to_destroy, to_keep = List.partition matches seat.pointer_bindings in
  List.iter (pointer_binding_destroy ctx) to_destroy;
  seat.pointer_bindings <- to_keep;
  not @@ List.is_empty to_destroy
;;

let pointer_binding_create (ctx : Ctx.manage Ctx.t) (seat : t) mode mods button command =
  let body = Request.Body.Command command in
  let binding : Pointer_binding.t =
    { obj =
        River.Window_management.River_seat_v1.get_pointer_binding
          seat.obj
          object
            inherit [_] River.Window_management.River_pointer_binding_v1.v4
            method on_released _ = ()

            method on_pressed _ =
              Queue.push Pending_request.{ body; reply = None } seat.pending_requests
          end
          ~button:(Pointer_button.to_int32 button)
          ~modifiers:mods
    ; seat
    ; mode
    ; enabled = String.equal mode (effective_mode ctx seat)
    ; command
    ; mods
    ; button
    }
  in
  River.Window_management.River_pointer_binding_v1.enable binding.obj;
  seat.pointer_bindings <- binding :: seat.pointer_bindings
;;

let replace_pointer_binding ctx seat mode mods button command =
  let replaced = unbind_pointer_binding ctx seat mode mods button in
  pointer_binding_create ctx seat mode mods button command;
  replaced
;;

let destroy ctx (s : t) =
  List.iter (xkb_binding_destroy ctx) s.xkb_bindings;
  List.iter (pointer_binding_destroy ctx) s.pointer_bindings;
  River.Layer_shell.River_layer_shell_seat_v1.destroy s.layer_shell;
  River.Window_management.River_seat_v1.destroy s.obj;
  Wayland.Proxy.delete s.obj
;;

let refresh_cursor_target (s : t) =
  match s.hovered with
  | Some _ -> s.cursor_target <- s.hovered
  | _ -> ()
;;

let op_end (_ : Ctx.manage Ctx.t) (s : t) =
  match s.op with
  | None -> ()
  | Some (Move _) | Some (Resize _) ->
    s.op <- None;
    River.Window_management.River_seat_v1.op_end s.obj
;;

let queue_pending wm (s : t) request =
  Queue.add request s.pending_requests;
  Dirty.mark_wm wm
;;

let drain_pending (s : t) = Queue.take_opt s.pending_requests

let clear_pending (s : t) =
  Queue.iter
    (fun (p : Pending_request.t) ->
       Option.iter (fun u -> Eio.Promise.resolve_error u "wm shutting down") p.reply)
    s.pending_requests;
  Queue.clear s.pending_requests
;;

let set_output (s : t) output =
  match s.output, output with
  | Some o, Some o' when o == o' -> ()
  | None, None -> ()
  | _ ->
    Option.iter Dirty.mark_output s.output;
    Option.iter Dirty.mark_output output;
    s.output <- output
;;

let focus_output (s : t) output =
  if not @@ Phys.opt_equal s.output output then set_output s output
;;

let set_layer_focus (s : t) layer =
  s.layer_focus <- layer;
  Dirty.mark_seat s
;;

let set_mode (ctx : Ctx.manage Ctx.t) (seat : t) mode =
  if not @@ List.mem mode (Ctx.wm ctx).config.modes
  then Error (Printf.sprintf "mode not declared: %S" mode)
  else if String.equal mode Mode.locked
  then Error "cannot enter 'locked' mode manually"
  else Ok (seat.mode <- mode)
;;

let set_position (s : t) position = s.position <- position
let set_cursor_target (s : t) window = s.cursor_target <- window
let set_focus_state (s : t) state = s.focus_state <- state
let set_op (s : t) op = s.op <- Some op
let clear_op (s : t) = s.op <- None

let set_op_delta (s : t) dx dy =
  match s.op with
  | Some (Move d) ->
    d.dx <- dx;
    d.dy <- dy
  | Some (Resize d) ->
    d.dx <- dx;
    d.dy <- dy
  | None -> ()
;;

let release_op (s : t) =
  match s.op with
  | Some (Move d) -> d.release <- true
  | Some (Resize d) -> d.release <- true
  | None -> ()
;;

let set_lifecycle (s : t) lifecycle = s.lifecycle <- lifecycle
let set_name (s : t) name = s.name <- name
let set_hovered (s : t) window = s.hovered <- window
let set_interacted (s : t) window = s.interacted <- window
let set_warp_request (s : t) v = s.warp_request <- v

let is_dirty (s : t) =
  match s.lifecycle with
  | Dirty _ -> true
  | _ -> false
;;

let bind ctx seat ?(mode = Mode.normal) mods (key : Types.Key.t) command =
  if not @@ List.mem mode (Ctx.wm ctx).config.modes
  then Error (Printf.sprintf "mode not declared: %S" mode)
  else
    Ok
      (match key with
       | Keysym keysym -> replace_xkb_binding ctx seat mode mods keysym command
       | Pointer button -> replace_pointer_binding ctx seat mode mods button command)
;;

let unbind ctx seat ?(mode = Mode.normal) mods (key : Types.Key.t) =
  if not @@ List.mem mode (Ctx.wm ctx).config.modes
  then Error (Printf.sprintf "mode not declared: %S" mode)
  else
    Ok
      (match key with
       | Keysym keysym -> unbind_xkb_binding ctx seat mode mods keysym
       | Pointer button -> unbind_pointer_binding ctx seat mode mods button)
;;

let focused_window (seat : t) =
  match seat.output with
  | Some o -> Output.focused_window o
  | None -> None
;;

let sync_bindings ctx (seat : t) =
  let active = effective_mode ctx seat in
  List.iter
    (fun (b : Xkb_binding.t) ->
       let desired = String.equal b.mode active in
       match desired, b.enabled with
       | true, true | false, false -> ()
       | true, false ->
         River.Xkb_bindings.River_xkb_binding_v1.enable b.obj;
         b.enabled <- desired
       | false, true ->
         River.Xkb_bindings.River_xkb_binding_v1.disable b.obj;
         b.enabled <- desired)
    seat.xkb_bindings;
  List.iter
    (fun (p : Pointer_binding.t) ->
       let desired = String.equal p.mode active in
       match desired, p.enabled with
       | true, true | false, false -> ()
       | true, false ->
         River.Window_management.River_pointer_binding_v1.enable p.obj;
         p.enabled <- desired
       | false, true ->
         River.Window_management.River_pointer_binding_v1.disable p.obj;
         p.enabled <- desired)
    seat.pointer_bindings
;;
