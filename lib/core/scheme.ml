open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Tile [@name "tile"]
  | Monocle [@name "monocle"]
[@@deriving yojson]

let all = [ Tile; Monocle ]

let to_string = function
  | Tile -> "tile"
  | Monocle -> "monocle"
;;

let of_string s =
  match String.trim s |> String.lowercase_ascii with
  | "tile" -> Some Tile
  | "monocle" -> Some Monocle
  | _ -> None
;;

let cycle s (dir : Direction.Logical.t) =
  match dir with
  | Next -> Ring.next_or_first s all |> Option.get
  | Prev -> Ring.prev_or_last s all |> Option.get
;;
