open! Ocdwm_core
include Types.Input_device

let role_to_string (role : Role.t) =
  match role with
  | Keyboard _ -> "keyboard"
  | Pointer -> "pointer"
  | Touch -> "touch"
  | Tablet -> "tablet"
;;

let set_keyboard (wm : Types.Wm.t) entry keyboard =
  match entry.role with
  | Keyboard k ->
    k.keyboard <- Some keyboard;
    (match wm.keymap with
     | Some keymap -> Emit.set_keymap keyboard ~keymap
     | None -> ())
  | Pointer | Touch | Tablet ->
    Logs.warn
    @@ fun m ->
    m "cannot set 'xkb' attribute for '%s' input device" @@ role_to_string entry.role
;;

let clear_entry entry proxy =
  match entry.role with
  | Keyboard k when Phys.opt_holds proxy k.keyboard -> k.keyboard <- None
  | Keyboard _ | Pointer | Touch | Tablet -> ()
;;

let remove_entry entry =
  match entry.lifecycle with
  | Removed -> ()
  | Active ->
    Emit.destroy_input_device entry.device;
    entry.lifecycle <- Removed
;;

let to_keyboard entry =
  match entry.role with
  | Keyboard { keyboard = Some _ as keyboard } -> keyboard
  | Keyboard _ | Pointer | Touch | Tablet -> None
;;

let id device = Wire.id device
