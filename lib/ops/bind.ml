open! Oxbow_core
open! Oxbow_ipc
open! Oxbow_state
open! Result.Syntax

type t =
  { mods : int32
  ; key : Types.Key.t
  }

let install_defaults (wm : Wm.t) seat =
  let modkey = wm.config.modkey in
  let ctrl = Wire.Modifiers.ctrl in
  let xkb_bindings =
    Xkbcommon.Keysym.
      [ (* mods, keysym,  command *)
        modkey, K_Return, Command.Spawn "foot"
      ; modkey, K_q, Command.Window (Close (One Focused))
      ; modkey, K_Q, Command.Session Exit
      ; ( modkey
        , K_j
        , Command.Window (Focus_logical { dir = Next; warp = None; target = Focused }) )
      ; ( modkey
        , K_k
        , Command.Window (Focus_logical { dir = Prev; warp = None; target = Focused }) )
      ; modkey, K_l, Command.Tag (View_cycle_occupied Next)
      ; modkey, K_h, Command.Tag (View_cycle_occupied Prev)
      ; modkey, K_Tab, Command.Tag (View_cycle Next)
      ; modkey, K_ISO_Left_Tab, Command.Tag (View_cycle Prev)
      ; modkey, K_t, Command.Layout (Select { layout = Tiling; scope = Focused })
      ; modkey, K_s, Command.Layout (Select { layout = Scrolling; scope = Focused })
      ; modkey, K_f, Command.Layout (Select { layout = Floating; scope = Focused })
      ; modkey, K_v, Command.Window (Toggle_fullscreen Focused)
      ; modkey, K_space, Command.Window (Zoom { warp = None; target = Focused })
      ; modkey, K_J, Command.Window (Shift { dir = Next; target = Focused })
      ; modkey, K_K, Command.Window (Shift { dir = Prev; target = Focused })
      ; modkey, K_y, Command.Layout (Tiling (Select { scheme = Even; scope = Focused }))
      ; ( modkey
        , K_i
        , Command.Layout (Tiling (Select { scheme = Monocle; scope = Focused })) )
      ; modkey, K_z, Command.Layout (Scrolling (Select { align = Left; scope = Focused }))
      ; ( modkey
        , K_x
        , Command.Layout (Scrolling (Select { align = Centered; scope = Focused })) )
      ; ( modkey
        , K_c
        , Command.Layout (Scrolling (Select { align = Visible; scope = Focused })) )
      ; modkey, K_comma, Command.Window (Column_consume Focused)
      ; modkey, K_period, Command.Window (Column_release Focused)
      ; ( Int32.(logor modkey ctrl)
        , K_l
        , Command.Window (Column_move { dir = Next; target = Focused }) )
      ; ( Int32.(logor modkey ctrl)
        , K_h
        , Command.Window (Column_move { dir = Prev; target = Focused }) )
      ; ( modkey
        , K_minus
        , Command.Window (Column_width { delta = Rel (-0.1); target = Focused }) )
      ; ( modkey
        , K_equal
        , Command.Window (Column_width { delta = Rel 0.1; target = Focused }) )
      ; modkey, K_r, Command.Window (Column_width_cycle Focused)
      ; modkey, K_R, Command.Window (Column_width_default Focused)
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
  List.iter (fun (m, k, a) -> ignore @@ Seat.bind wm seat m (Keysym k) a) xkb_bindings;
  List.iter
    (fun (m, b, a) -> ignore @@ Seat.bind wm seat m (Pointer b) a)
    pointer_bindings
;;

let parse_modifier = function
  | "Shift" -> Ok Wire.Modifiers.shift
  | "Control" -> Ok Wire.Modifiers.ctrl
  | "Mod1" | "Alt" -> Ok Wire.Modifiers.mod1
  | "Mod3" -> Ok Wire.Modifiers.mod3
  | "Mod4" | "Super" | "Logo" -> Ok Wire.Modifiers.mod4
  | "Mod5" -> Ok Wire.Modifiers.mod5
  | "None" -> Ok Wire.Modifiers.none
  | s -> Error (Printf.sprintf "unrecognized modifier: %S" s)
;;

let parse_modifiers s =
  String.split_on_char '+' s
  |> List.map String.trim
  |> List.fold_left
       (fun acc part ->
          let* mods = acc in
          let+ m = parse_modifier part in
          Int32.logor mods m)
       (Ok 0l)
;;

(** [parse_keysym name] is the keysym represented by [name]. See:
    - https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
    - https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon.h
      (check the comments for [xkb_keysym_from_name] and [xkb_keysym_t].)

    TL;DR to get the keysym [XKB_KEY_space] use everything after [XKB_KEY_]:
    - {b space}: [XKB_KEY_space]
    - {b plus}: [XKB_KEY_plus] *)
let parse_keysym s =
  match Xkbcommon.Keysym.from_name ~case_insensitive:true s with
  | Xkbcommon.Keysym.K_NoSymbol -> Error (Printf.sprintf "unrecognized keysym name: %S" s)
  | keysym -> Ok keysym
;;

(** [parse_button s] maps recognized button strings to [Pointer_button.t]
    representations. Recognized strings include:
    - {b Btn_0}
    - {b Btn_1}
    - {b Btn_2}
    - {b Btn_3}
    - {b Btn_4}
    - {b Btn_5}
    - {b Btn_6}
    - {b Btn_7}
    - {b Btn_8}
    - {b Btn_9}
    - {b Btn_left}
    - {b Btn_right}
    - {b Btn_middle}
    - {b Btn_side}
    - {b Btn_extra}
    - {b Btn_forward}
    - {b Btn_back}
    - {b Btn_task}

    Any other string returns [Error "unrecognized"]. *)
let parse_button = Pointer_button.of_string

(** [parse s] is the [{mods; key}] represented by s. [s] is a string of zero or
    more modifiers, and a keysym or button combined with '+':
    - {b Super+space}
    - {b Super+Control+Btn_left}
    - {b plus}|{b Btn_middle}

    See [parse_modifiers], [parse_keysym], and [parse_button] for more details. *)
let parse s =
  let parts = String.split_on_char '+' s |> List.map String.trim in
  let rec aux mods = function
    | [ x ] ->
      (match parse_button x with
       | Error _ ->
         let+ keysym = parse_keysym x in
         { mods; key = Keysym keysym }
       | Ok button -> Ok { mods; key = Pointer button })
    | x :: xs ->
      let* m = parse_modifier x in
      aux (Int32.logor mods m) xs
    | [] -> Error (Printf.sprintf "internal error, got no parts: %S" s)
  in
  aux 0l parts
;;

(** [format_modifiers mods] is the modifier names set in [mods], in the
    canonical order Super, Alt, Control, Shift, Mod3, Mod5. Empty when [mods] is
    [0l]. *)
let format_modifiers mods =
  let open Wire in
  List.filter_map
    (fun (m, r) -> if Int32.logand m mods <> 0l then Some r else None)
    [ Modifiers.mod4, "Super"
    ; Modifiers.mod1, "Alt"
    ; Modifiers.ctrl, "Control"
    ; Modifiers.shift, "Shift"
    ; Modifiers.mod3, "Mod3"
    ; Modifiers.mod5, "Mod5"
    ]
;;

(** [format_keybind mods key] is the keybind string for [mods] and [key]: the
    inverse of [parse]. [parse (format_keybind mods key)] is [Ok { mods; key }]. *)
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
      [ "mode", `String (Mode.to_string mode)
      ; "keybind", `String keybind
      ; "command", Command.yojson_of_t command
      ]
  in
  let seat_json (s : Seat.t) =
    let bindings =
      List.concat_map
        (fun mode ->
           List.filter_map
             (fun (xkb : Seat.Xkb_binding.t) ->
                if Mode.equal mode xkb.mode
                then
                  Some
                    (entry mode (format_keybind xkb.mods (Keysym xkb.keysym)) xkb.command)
                else None)
             s.xkb_bindings
           @ List.filter_map
               (fun (p : Seat.Pointer_binding.t) ->
                  if Mode.equal mode p.mode
                  then
                    Some (entry mode (format_keybind p.mods (Pointer p.button)) p.command)
                  else None)
               s.pointer_bindings)
        wm.config.modes
    in
    `Assoc
      [ ( "seat"
        , match s.name with
          | Some n -> `String n
          | None -> `Null )
      ; "mode", `String (Mode.to_string s.mode)
      ; "bindings", `List bindings
      ]
  in
  if all then `List (List.map seat_json wm.seats) else seat_json seat
;;

let handle (wm : Wm.t) seat (keymap : Keymap.t) =
  let resolve_mode = function
    | None -> Ok None
    | Some m ->
      let+ mode = Mode.resolve m ~declared:wm.config.modes in
      Some mode
  in
  match keymap with
  | Bind bind ->
    let* { mods; key } = parse bind.keybind in
    let+ mode = resolve_mode bind.mode in
    if Seat.bind wm seat ?mode mods key bind.command
    then Some (`String (Printf.sprintf "overwrote existing binding for %S" bind.keybind))
    else None
  | Unbind bind ->
    let* { mods; key } = parse bind.keybind in
    let* mode = resolve_mode bind.mode in
    if Seat.unbind seat ?mode mods key
    then Ok None
    else Error (Printf.sprintf "no binding for %S" bind.keybind)
;;
