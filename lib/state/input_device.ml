open! Ocdwm_core
include Types.Input_device

let role_to_string (role : Role.t) =
  match role with
  | Keyboard _ -> "keyboard"
  | Pointer { class_ } -> Input.Class.to_string class_
  | Touch -> "touch"
  | Tablet -> "tablet"
;;

let set_keyboard (wm : Types.Wm.t) device keyboard =
  match device.role with
  | Keyboard k ->
    k.keyboard <- Some keyboard;
    (match wm.keymap with
     | Some keymap -> Emit.set_keymap keyboard ~keymap
     | None -> ())
  | Pointer _ | Touch | Tablet ->
    Logs.warn
    @@ fun m ->
    m "cannot set 'xkb' attribute for '%s' input device" @@ role_to_string device.role
;;

let clear_device device proxy =
  match device.role with
  | Keyboard k when Phys.opt_holds proxy k.keyboard -> k.keyboard <- None
  | Keyboard _ | Pointer _ | Touch | Tablet -> ()
;;

let remove_device device =
  match device.lifecycle with
  | Removed -> ()
  | Active ->
    Emit.destroy_input_device device.obj;
    device.lifecycle <- Removed
;;

let id proxy = Wire.id proxy

let matches device ~pattern ~(case : Pattern.Case.t) ~(role : Input.Role.t option) =
  let matches_role =
    match device.role, role with
    | Keyboard _, Some Keyboard -> true
    | Pointer { class_ = Mouse }, Some Mouse -> true
    | Pointer { class_ = Touchpad }, Some Touchpad -> true
    | Touch, Some Touch -> true
    | Tablet, Some Tablet -> true
    | _, None -> true
    | _ -> false
  in
  if not matches_role then false else Pattern.matches ~case ~pattern device.name
;;
