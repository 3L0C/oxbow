type code =
  | Key_unknown
  | Btn_left
  | Btn_right

let of_int32 = function
  | 0x110l -> Btn_left
  | 0x111l -> Btn_right
  | _ -> Key_unknown
;;

let to_int32 = function
  | Btn_left -> 0x110l
  | Btn_right -> 0x111l
  | Key_unknown -> 240l
;;
