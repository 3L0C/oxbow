type t =
  | Even [@name "even"]
  | Diminish [@name "diminish"]
  | Dwindle [@name "dwindle"]
  | Spiral [@name "spiral"]
[@@deriving yojson]

let all = [ Even; Diminish; Dwindle; Spiral ]

let to_string = function
  | Even -> "even"
  | Diminish -> "diminish"
  | Dwindle -> "dwindle"
  | Spiral -> "spiral"
;;

let of_string s =
  match String.lowercase_ascii s |> String.trim with
  | "even" -> Some Even
  | "diminish" -> Some Diminish
  | "dwindle" -> Some Dwindle
  | "spiral" -> Some Spiral
  | _ -> None
;;

let cycle t (dir : Direction.Logical.t) =
  match dir with
  | Next -> Ring.next_or_first t all |> Option.get
  | Prev -> Ring.prev_or_last t all |> Option.get
;;
