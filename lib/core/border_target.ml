type t =
  | Focused [@name "focused"]
  | Unfocused [@name "unfocused"]
  | Urgent [@name "urgent"]
  | Swallowing [@name "swallowing"]
[@@deriving yojson]

let all = [ Focused; Unfocused; Urgent; Swallowing ]

let to_string = function
  | Focused -> "focused"
  | Unfocused -> "unfocused"
  | Urgent -> "urgent"
  | Swallowing -> "swallowing"
;;
