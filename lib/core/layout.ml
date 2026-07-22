open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Tiling [@name "tiling"]
  | Scrolling [@name "scrolling"]
  | Floating [@name "floating"]
[@@deriving yojson]

let to_string = function
  | Tiling -> "tiling"
  | Scrolling -> "scrolling"
  | Floating -> "floating"
;;

let of_string s =
  match String.trim s |> String.lowercase_ascii with
  | "tiling" -> Some Tiling
  | "scrolling" -> Some Scrolling
  | "floating" -> Some Floating
  | _ -> None
;;
