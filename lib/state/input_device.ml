open! Ocdwm_core
include Types.Input_device

let role_to_string (role : Role.t) =
  match role with
  | Keyboard _ -> "keyboard"
  | Pointer -> "pointer"
  | Touch -> "touch"
  | Tablet -> "tablet"
;;

let set_xkb (wm : Types.Wm.t) (entry : t) xkb =
  match entry.role with
  | Keyboard k ->
    k.xkb <- Some xkb;
    (match wm.keymap with
     | Some keymap -> Send.set_keymap xkb ~keymap
     | None -> ())
  | Pointer | Touch | Tablet ->
    Logs.warn
    @@ fun m ->
    m "cannot set 'xkb' attribute for '%s' input device" @@ role_to_string entry.role
;;

let clear_xkb (entry : t) xkb =
  match entry.role with
  | Keyboard k when Phys.opt_holds xkb k.xkb -> k.xkb <- None
  | Keyboard _ | Pointer | Touch | Tablet -> ()
;;

let remove_entry (entry : t) =
  match entry.lifecycle with
  | Removed -> ()
  | Active ->
    Emit.destroy_input_device entry.device;
    entry.lifecycle <- Removed
;;

let to_xkb (entry : t) =
  match entry.role with
  | Keyboard { xkb = Some xkb } -> Some xkb
  | Keyboard _ | Pointer | Touch | Tablet -> None
;;
