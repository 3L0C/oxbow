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
  let ctrl = River.Window_management.River_seat_v1.Modifiers.ctrl in
  let xkb_bindings =
    Xkbcommon.Keysym.
      [ (* mods, keysym,  command *)
        modkey, K_Return, Command.Execute (Spawn "kitty")
      ; modkey, K_q, Command.Window Close
      ; modkey, K_j, Command.Window (Focus_logical { dir = Next; warp = None })
      ; modkey, K_k, Command.Window (Focus_logical { dir = Prev; warp = None })
      ; modkey, K_Escape, Command.Wm Close
      ; Int32.(logor modkey shift), K_Escape, Command.Session Exit
      ; modkey, K_l, Command.Tag (View_cycle_occupied Next)
      ; modkey, K_h, Command.Tag (View_cycle_occupied Prev)
      ; modkey, K_Tab, Command.Tag (View_cycle Next)
      ; modkey, K_ISO_Left_Tab, Command.Tag (View_cycle Prev)
      ; Int32.(logor modkey alt), K_Tab, Command.Layout (Cycle Next)
      ; Int32.(logor modkey alt), K_ISO_Left_Tab, Command.Layout (Cycle Prev)
      ; modkey, K_t, Command.Set (Layout { layout = Tiling; global = false })
      ; modkey, K_s, Command.Set (Layout { layout = Scrolling; global = false })
      ; modkey, K_f, Command.Set (Layout { layout = Floating; global = false })
      ; Int32.(logor modkey shift), K_space, Command.Window Toggle_floating
      ; modkey, K_v, Command.Window Toggle_fullscreen
      ; modkey, K_I, Command.Window Toggle_fake_fullscreen
      ; modkey, K_F, Command.Window Toggle_maximize
      ; modkey, K_H, Command.Set (Mfact { delta = Delta.(Rel (-0.05)); global = false })
      ; modkey, K_L, Command.Set (Mfact { delta = Delta.(Rel 0.05); global = false })
      ; modkey, K_a, Command.Set (Mfact { delta = Delta.(Abs 0.55); global = false })
      ; modkey, K_space, Command.Window (Zoom { warp = None })
      ; modkey, K_J, Command.Window (Shift Next)
      ; modkey, K_K, Command.Window (Shift Prev)
      ; modkey, K_y, Command.Set (Scheme { scheme = Even; global = false })
      ; modkey, K_i, Command.Set (Scheme { scheme = Monocle; global = false })
      ; modkey, K_comma, Command.Window Column_consume
      ; modkey, K_period, Command.Window Column_release
      ; Int32.(logor modkey ctrl), K_h, Command.Window (Column_move Prev)
      ; Int32.(logor modkey ctrl), K_l, Command.Window (Column_move Next)
      ; modkey, K_minus, Command.Window (Column_width (Rel (-0.1)))
      ; modkey, K_equal, Command.Window (Column_width (Rel 0.1))
      ; modkey, K_r, Command.Window Column_width_cycle
      ; modkey, K_R, Command.Window Column_width_default
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
  List.iter (fun (m, k, a) -> ignore @@ Seat.bind ctx seat m (Keysym k) a) xkb_bindings;
  List.iter
    (fun (m, b, a) -> ignore @@ Seat.bind ctx seat m (Pointer b) a)
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

let format_modifiers mods =
  List.fold_left
    (fun acc (m, r) -> if Int32.logand m mods <> 0l then acc @ [ r ] else acc)
    []
    [ Modifiers.mod4, "Super"
    ; Modifiers.mod1, "Alt"
    ; Modifiers.ctrl, "Control"
    ; Modifiers.shift, "Shift"
    ; Modifiers.mod3, "Mod3"
    ; Modifiers.mod5, "Mod5"
    ]
;;

let format_keybind mods (key : Types.Key.t) =
  let key_name =
    match key with
    | Keysym keysym -> Xkbcommon.Keysym.get_name keysym
    | Pointer button -> Pointer_button.to_string button
  in
  String.concat "+" (format_modifiers mods @ [ key_name ])
;;

let list (wm : Wm.t) (seat : Seat.t) ~all =
  let entry mode keybind command =
    `Assoc
      [ "mode", `String mode
      ; "keybind", `String keybind
      ; "command", Command.yojson_of_t command
      ]
  in
  let seat_json (s : Seat.t) =
    let bindings =
      List.concat_map
        (fun mode ->
           List.fold_left
             (fun acc (xkb : Seat.Xkb_binding.t) ->
                if String.equal mode xkb.mode
                then
                  entry mode (format_keybind xkb.mods (Keysym xkb.keysym)) xkb.command
                  :: acc
                else acc)
             []
             s.xkb_bindings
           @ List.fold_left
               (fun acc (p : Seat.Pointer_binding.t) ->
                  if String.equal mode p.mode
                  then
                    entry mode (format_keybind p.mods (Pointer p.button)) p.command :: acc
                  else acc)
               []
               s.pointer_bindings)
        wm.config.modes
    in
    `Assoc
      [ ( "seat"
        , match s.name with
          | Some n -> `String n
          | None -> `Null )
      ; "mode", `String s.mode
      ; "bindings", `List bindings
      ]
  in
  if all then `List (List.map seat_json wm.seats) else seat_json seat
;;

let handle ctx seat (keymap : Keymap.t) =
  match keymap with
  | Bind bind ->
    (match parse bind.keybind with
     | Error _ as e -> e
     | Ok { mods; key } ->
       (match Seat.bind ctx seat ?mode:bind.mode mods key bind.command with
        | Error _ as e -> e
        | Ok true ->
          Ok
            (Some
               (`String (Printf.sprintf "overwrote existing binding for %S" bind.keybind)))
        | Ok false -> Ok None))
  | Unbind bind ->
    (match parse bind.keybind with
     | Error msg -> Error msg
     | Ok { mods; key } ->
       (match Seat.unbind ctx seat ?mode:bind.mode mods key with
        | Error _ as e -> e
        | Ok true -> Ok None
        | Ok false -> Error (Printf.sprintf "no binding for %S" bind.keybind)))
;;
