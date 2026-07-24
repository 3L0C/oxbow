open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Even [@name "even"]
  | Diminish [@name "diminish"]
  | Dwindle [@name "dwindle"]
  | Spiral [@name "spiral"]
  | Monocle [@name "monocle"]
[@@deriving yojson]

let all = [ Even; Diminish; Dwindle; Spiral; Monocle ]

let to_string = function
  | Even -> "even"
  | Diminish -> "diminish"
  | Dwindle -> "dwindle"
  | Spiral -> "spiral"
  | Monocle -> "monocle"
;;

let of_string s =
  match String.trim s |> String.lowercase_ascii with
  | "even" -> Some Even
  | "diminish" -> Some Diminish
  | "dwindle" -> Some Dwindle
  | "spiral" -> Some Spiral
  | "monocle" -> Some Monocle
  | _ -> None
;;

let cycle t (dir : Direction.Logical.t) =
  match dir with
  | Next -> Ring.next_or_first t all |> Option.get
  | Prev -> Ring.prev_or_last t all |> Option.get
;;
