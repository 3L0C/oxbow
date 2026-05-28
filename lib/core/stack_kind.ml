type t =
  | Stack_even [@name "stack_even"]
  | Stack_diminish [@name "stack_diminish"]
  | Stack_dwindle [@name "stack_dwindle"]
[@@deriving yojson]

let to_string = function
  | Stack_even -> "even"
  | Stack_diminish -> "diminish"
  | Stack_dwindle -> "dwindle"
;;

let of_string s =
  match String.lowercase_ascii s |> String.trim with
  | "even" -> Some Stack_even
  | "diminish" -> Some Stack_diminish
  | "dwindle" -> Some Stack_dwindle
  | _ -> None
;;
