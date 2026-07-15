open! Ocdwm_core
open! Ocdwm_state
module Modifiers = River.Window_management.River_seat_v1.Modifiers

type t =
  { mods : int32
  ; key : Types.Key.t
  }

let install_defaults ctx seat =
  let wm = Ctx.wm ctx in
  let modkey = wm.config.modkey in
  let alt = River.Window_management.River_seat_v1.Modifiers.mod1 in
  let shift = River.Window_management.River_seat_v1.Modifiers.shift in
  let xkb_bindings =
    Xkbcommon.Keysym.
      [ (* mods, keysym,   action *)
        modkey, K_Return, Action.Spawn "kitty"
      ; modkey, K_q, Action.Close_focused
      ; modkey, K_j, Action.Focus_window_logical Next
      ; modkey, K_k, Action.Focus_window_logical Prev
      ; modkey, K_Escape, Action.Close_wm
      ; Int32.(logor modkey shift), K_Escape, Action.Exit_session
      ; modkey, K_h, Action.Tag_view_cycle Prev
      ; modkey, K_l, Action.Tag_view_cycle Next
      ; modkey, K_Tab, Action.Tag_view_cycle Next
      ; modkey, K_ISO_Left_Tab, Action.Tag_view_cycle Prev
      ; Int32.(logor modkey alt), K_Tab, Layout_cycle Next
      ; Int32.(logor modkey alt), K_ISO_Left_Tab, Layout_cycle Prev
      ; Int32.(logor modkey shift), K_space, Toggle_floating
      ; modkey, K_v, Toggle_fullscreen
      ; modkey, K_I, Toggle_fake_fullscreen
      ; modkey, K_F, Toggle_maximize
      ; modkey, K_H, Set_mfact Delta.(Rel (-0.05))
      ; modkey, K_L, Set_mfact Delta.(Rel 0.05)
      ; modkey, K_a, Set_mfact Delta.(Abs 0.55)
      ; modkey, K_space, Zoom
      ; modkey, K_J, Shift Next
      ; modkey, K_K, Shift Prev
      ]
  in
  let num_keys = Xkbcommon.Keysym.[ K_1; K_2; K_3; K_4; K_5; K_6; K_7; K_8; K_9 ] in
  let num_bindings =
    List.mapi
      (fun i keysym ->
         modkey, keysym, Action.Tag_view (Concrete (Tag.Set.singleton (i + 1))))
      num_keys
  in
  let xkb_bindings = num_bindings @ xkb_bindings in
  let pointer_bindings =
    Pointer_button.
      [ (* mods, keysym,   action *)
        modkey, Btn_left, Action.Move_interactive
      ; modkey, Btn_right, Action.Resize_interactive
      ]
  in
  List.iter (fun (m, k, a) -> Seat.replace_xkb_binding ctx seat m k a) xkb_bindings;
  List.iter
    (fun (m, ec, a) -> Seat.replace_pointer_binding ctx seat m ec a)
    pointer_bindings
;;

let parse_modifiers = function
  | "Shift" -> Ok Modifiers.shift
  | "Control" -> Ok Modifiers.ctrl
  | "Mod1" | "Alt" -> Ok Modifiers.mod1
  | "Mod3" -> Ok Modifiers.mod3
  | "Mod4" | "Super" | "Logo" -> Ok Modifiers.mod4
  | "Mod5" -> Ok Modifiers.mod5
  | "None" -> Ok Modifiers.none
  | s -> Error (Printf.sprintf "unrecognized modifier: %S" s)
;;

let parse_keysym s =
  match Xkbcommon.Keysym.from_name ~case_insensitive:true s with
  | Xkbcommon.Keysym.K_NoSymbol -> Error (Printf.sprintf "unrecognized keysym name: %S" s)
  | keysym -> Ok keysym
;;

let parse_button = Pointer_button.of_string

let parse s =
  let parts = String.split_on_char '+' s |> List.map String.trim in
  let rec aux mods = function
    | [ x ] ->
      (match parse_button x with
       | Error _ ->
         (match parse_keysym x with
          | Error _ as e -> e
          | Ok keysym -> Ok { mods; key = Keysym keysym })
       | Ok button -> Ok { mods; key = Pointer button })
    | x :: xs ->
      (match parse_modifiers x with
       | Error _ as e -> e
       | Ok m -> aux (Int32.logor mods m) xs)
    | [] -> Error (Printf.sprintf "internal error, got no parts: %S" s)
  in
  aux 0l parts
;;

let handle ctx seat (setting : Setting.t) =
  match setting with
  | Bind bind ->
    (match parse bind.keybind with
     | Error msg -> Error msg
     | Ok { mods; key } ->
       Seat.bind ctx seat mods key bind.action;
       Ok None)
  | Unbind bind ->
    (match parse bind with
     | Error msg -> Error msg
     | Ok { mods; key } ->
       Seat.unbind ctx seat mods key;
       Ok None)
;;
