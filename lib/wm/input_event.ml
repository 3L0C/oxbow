type t =
  | Key_unknown
  | Btn_0
  | Btn_1
  | Btn_2
  | Btn_3
  | Btn_4
  | Btn_5
  | Btn_6
  | Btn_7
  | Btn_8
  | Btn_9
  | Btn_left
  | Btn_right
  | Btn_middle
  | Btn_side
  | Btn_extra
  | Btn_forward
  | Btn_back
  | Btn_task

let of_string = function
  | "Btn_0" -> Ok Btn_0
  | "Btn_1" -> Ok Btn_1
  | "Btn_2" -> Ok Btn_2
  | "Btn_3" -> Ok Btn_3
  | "Btn_4" -> Ok Btn_4
  | "Btn_5" -> Ok Btn_5
  | "Btn_6" -> Ok Btn_6
  | "Btn_7" -> Ok Btn_7
  | "Btn_8" -> Ok Btn_8
  | "Btn_9" -> Ok Btn_9
  | "Btn_left" -> Ok Btn_left
  | "Btn_right" -> Ok Btn_right
  | "Btn_middle" -> Ok Btn_middle
  | "Btn_side" -> Ok Btn_side
  | "Btn_extra" -> Ok Btn_extra
  | "Btn_forward" -> Ok Btn_forward
  | "Btn_back" -> Ok Btn_back
  | "Btn_task" -> Ok Btn_task
  | s -> Error (Printf.sprintf "unrecognized input event: %S" s)
;;

let to_string = function
  | Btn_0 -> "Btn_0"
  | Btn_1 -> "Btn_1"
  | Btn_2 -> "Btn_2"
  | Btn_3 -> "Btn_3"
  | Btn_4 -> "Btn_4"
  | Btn_5 -> "Btn_5"
  | Btn_6 -> "Btn_6"
  | Btn_7 -> "Btn_7"
  | Btn_8 -> "Btn_8"
  | Btn_9 -> "Btn_9"
  | Btn_left -> "Btn_left"
  | Btn_right -> "Btn_right"
  | Btn_middle -> "Btn_middle"
  | Btn_side -> "Btn_side"
  | Btn_extra -> "Btn_extra"
  | Btn_forward -> "Btn_forward"
  | Btn_back -> "Btn_back"
  | Btn_task -> "Btn_task"
  | Key_unknown -> "Key_unknown"
;;

let of_int32 = function
  | 0x100l -> Btn_0
  | 0x101l -> Btn_1
  | 0x102l -> Btn_2
  | 0x103l -> Btn_3
  | 0x104l -> Btn_4
  | 0x105l -> Btn_5
  | 0x106l -> Btn_6
  | 0x107l -> Btn_7
  | 0x108l -> Btn_8
  | 0x109l -> Btn_9
  | 0x110l -> Btn_left
  | 0x111l -> Btn_right
  | 0x112l -> Btn_middle
  | 0x113l -> Btn_side
  | 0x114l -> Btn_extra
  | 0x115l -> Btn_forward
  | 0x116l -> Btn_back
  | 0x117l -> Btn_task
  | _ -> Key_unknown
;;

let to_int32 = function
  | Btn_0 -> 0x100l
  | Btn_1 -> 0x101l
  | Btn_2 -> 0x102l
  | Btn_3 -> 0x103l
  | Btn_4 -> 0x104l
  | Btn_5 -> 0x105l
  | Btn_6 -> 0x106l
  | Btn_7 -> 0x107l
  | Btn_8 -> 0x108l
  | Btn_9 -> 0x109l
  | Btn_left -> 0x110l
  | Btn_right -> 0x111l
  | Btn_middle -> 0x112l
  | Btn_side -> 0x113l
  | Btn_extra -> 0x114l
  | Btn_forward -> 0x115l
  | Btn_back -> 0x116l
  | Btn_task -> 0x117l
  | Key_unknown -> 240l
;;
