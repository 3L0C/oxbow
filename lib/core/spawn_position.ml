type t =
  | Master [@name "master"]
  | Prev [@name "prev"]
  | Next [@name "next"]
  | End [@name "end"]
[@@deriving yojson]

let all = [ Master; Prev; Next; End ]

let to_string = function
  | Master -> "master"
  | Prev -> "prev"
  | Next -> "next"
  | End -> "end"
;;
