open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Up [@name "up"]
  | Down [@name "down"]
  | Left [@name "left"]
  | Right [@name "right"]
[@@deriving yojson]

let to_string = function
  | Up -> "up"
  | Down -> "down"
  | Left -> "left"
  | Right -> "right"
;;

let of_string s =
  match String.lowercase_ascii s |> String.trim with
  | "up" -> Some Up
  | "down" -> Some Down
  | "left" -> Some Left
  | "right" -> Some Right
  | _ -> None
;;
