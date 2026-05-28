open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Next [@name "next"]
  | Prev [@name "prev"]
[@@deriving yojson]

let to_string = function
  | Next -> "next"
  | Prev -> "prev"
;;

let of_string s =
  match String.lowercase_ascii s |> String.trim with
  | "next" -> Some Next
  | "prev" -> Some Prev
  | _ -> None
;;
