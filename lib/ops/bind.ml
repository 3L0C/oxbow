open! Ocdwm_core
open! Ocdwm_ipc
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
      [ (* mods, keysym,  command *)
        modkey, K_Return, Command.Execute (Spawn "uwsm-app -- kitty")
      ; modkey, K_q, Command.Window Close
      ; modkey, K_j, Command.Window (Focus_logical Next)
      ; modkey, K_k, Command.Window (Focus_logical Prev)
      ; modkey, K_Escape, Command.Wm Close
      ; Int32.(logor modkey shift), K_Escape, Command.Session Exit
      ; modkey, K_l, Command.Tag (View_cycle_occupied Next)
      ; modkey, K_h, Command.Tag (View_cycle_occupied Prev)
      ; modkey, K_Tab, Command.Tag (View_cycle Next)
      ; modkey, K_ISO_Left_Tab, Command.Tag (View_cycle Prev)
      ; Int32.(logor modkey alt), K_Tab, Command.Layout (Cycle Next)
      ; Int32.(logor modkey alt), K_ISO_Left_Tab, Command.Layout (Cycle Prev)
      ; Int32.(logor modkey shift), K_space, Command.Window Toggle_floating
      ; modkey, K_v, Command.Window Toggle_fullscreen
      ; modkey, K_I, Command.Window Toggle_fake_fullscreen
      ; modkey, K_F, Command.Window Toggle_maximize
      ; modkey, K_H, Command.Set (Mfact Delta.(Rel (-0.05)))
      ; modkey, K_L, Command.Set (Mfact Delta.(Rel 0.05))
      ; modkey, K_a, Command.Set (Mfact Delta.(Abs 0.55))
      ; modkey, K_space, Command.Window Zoom
      ; modkey, K_J, Command.Window (Shift Next)
      ; modkey, K_K, Command.Window (Shift Prev)
      ; modkey, K_comma, Command.Execute (Spawn "uwsm-app -- wk-river")
      ; modkey, K_i, Command.Set (Layout "monocle")
      ; modkey, K_y, Command.Set (Layout "tile")
      ]
  in
  let num_keys = Xkbcommon.Keysym.[ K_1; K_2; K_3; K_4; K_5; K_6; K_7; K_8; K_9 ] in
  let num_bindings =
    List.mapi
      (fun i keysym ->
         modkey, keysym, Command.Tag (View (Concrete (Tag.Set.singleton (i + 1)))))
      num_keys
  in
  let xkb_bindings = num_bindings @ xkb_bindings in
  let pointer_bindings =
    Pointer_button.
      [ (* mods, button,  command *)
        modkey, Btn_left, Command.Window Move_drag
      ; modkey, Btn_right, Command.Window Resize_drag
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

let handle ctx seat (keymap : Keymap.t) =
  match keymap with
  | Bind bind ->
    (match parse bind.keybind with
     | Error msg -> Error msg
     | Ok { mods; key } ->
       Seat.bind ctx seat mods key bind.command;
       Ok None)
  | Unbind bind ->
    (match parse bind with
     | Error msg -> Error msg
     | Ok { mods; key } ->
       Seat.unbind ctx seat mods key;
       Ok None)
;;
