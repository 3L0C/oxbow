type t =
  | Never [@name "never"]
  | Always [@name "always"]
  | Not_scrolling [@name "not_scrolling"]
[@@deriving yojson]

let all = [ Never; Always; Not_scrolling ]

let to_string = function
  | Never -> "never"
  | Always -> "always"
  | Not_scrolling -> "not-scrolling"
;;

let cycle = function
  | Never -> Always
  | Always -> Not_scrolling
  | Not_scrolling -> Never
;;
