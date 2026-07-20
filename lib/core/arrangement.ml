type t =
  | Tiling [@name "tiling"]
  | Scrolling [@name "scrolling"]
  | Overview of [ `Tiling | `Scrolling ] [@name "overview"]
[@@deriving yojson]

let to_string = function
  | Tiling -> "tiling"
  | Overview _ -> "overview"
  | Scrolling -> "scrolling"
;;

let of_string s =
  match String.lowercase_ascii s |> String.trim with
  | "tiling" -> Some Tiling
  | "overview" -> Some (Overview `Tiling)
  | "scrolling" -> Some Scrolling
  | _ -> None
;;
