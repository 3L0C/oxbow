open! Ppx_yojson_conv_lib.Yojson_conv

module Logical = struct
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
end

module Spatial = struct
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
end

type t =
  | Logical of Logical.t [@name "logical"]
  | Spatial of Spatial.t [@name "spatial"]
[@@deriving yojson]

let to_string = function
  | Logical d -> Logical.to_string d
  | Spatial d -> Spatial.to_string d
;;

let of_string s =
  match Logical.of_string s with
  | Some d -> Some (Logical d)
  | None ->
    (match Spatial.of_string s with
     | Some d -> Some (Spatial d)
     | None -> None)
;;
