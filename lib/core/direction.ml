type t =
  | Dir_next [@name "next"]
  | Dir_prev [@name "prev"]
  | Dir_left [@name "left"]
  | Dir_right [@name "right"]
  | Dir_up [@name "up"]
  | Dir_down [@name "down"]
[@@deriving yojson]

let to_string = function
  | Dir_next -> "next"
  | Dir_prev -> "prev"
  | Dir_left -> "left"
  | Dir_right -> "right"
  | Dir_up -> "up"
  | Dir_down -> "down"
;;
