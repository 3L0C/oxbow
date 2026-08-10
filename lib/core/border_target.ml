type t =
  | Focused [@name "focused"]
  | Unfocused [@name "unfocused"]
  | Urgent [@name "urgent"]
  | Swallowing [@name "swallowing"]
  | Captured [@name "captured"]
[@@deriving yojson]

let all = [ Focused; Unfocused; Urgent; Swallowing; Captured ]

let to_string = function
  | Focused -> "focused"
  | Unfocused -> "unfocused"
  | Urgent -> "urgent"
  | Swallowing -> "swallowing"
  | Captured -> "captured"
;;
