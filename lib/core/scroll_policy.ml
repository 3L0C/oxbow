open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Visible [@name "visible"]
  | Left [@name "left"]
  | Centered [@name "centered"]
[@@deriving yojson]

let to_string = function
  | Visible -> "visible"
  | Left -> "left"
  | Centered -> "centered"
;;

let of_string = function
  | "visible" -> Ok Visible
  | "left" -> Ok Left
  | "centered" -> Ok Centered
  | s -> Error (Printf.sprintf "unrecognized scroll policy: %S" s)
;;
