module Modifiers =
  Ocdwm_protocol.River_window_management_v1_client.River_seat_v1.Modifiers

type key =
  | Keysym of Xkbcommon.Keysym.t
  | Pointer of Input_event.t

type t =
  { mods : int32
  ; key : key
  }

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

let parse_button = Input_event.of_string

let parse str =
  let parts = String.split_on_char '+' str |> List.map String.trim in
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
    | [] -> Error (Printf.sprintf "internal error, got no parts: %S" str)
  in
  aux 0l parts
;;
