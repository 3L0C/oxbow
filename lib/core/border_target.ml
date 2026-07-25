type t =
  | Focused [@name "focused"]
  | Unfocused [@name "unfocused"]
  | Urgent [@name "urgent"]
[@@deriving yojson]
