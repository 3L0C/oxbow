type t =
  | Dir_next [@name "next"]
  | Dir_prev [@name "prev"]
  | Dir_left [@name "left"]
  | Dir_right [@name "right"]
  | Dir_up [@name "up"]
  | Dir_down [@name "down"]
[@@deriving yojson]
