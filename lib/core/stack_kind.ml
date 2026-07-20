type t =
  | Even [@name "even"]
  | Diminish [@name "diminish"]
  | Dwindle [@name "dwindle"]
  | Spiral [@name "spiral"]
[@@deriving yojson]

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
