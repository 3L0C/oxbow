type t =
  | Next [@name "next"]
  | Prev [@name "prev"]
[@@deriving yojson]

let to_string = function
  | Next -> "next"
  | Prev -> "prev"
;;

let of_string = function
  | "next" -> Some Next
  | "prev" -> Some Prev
  | _ -> None
;;
