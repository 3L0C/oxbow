open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Logical of Logical_direction.t [@name "logical"]
  | Spatial of Spatial_direction.t [@name "spatial"]
[@@deriving yojson]

let to_string = function
  | Logical d -> Logical_direction.to_string d
  | Spatial d -> Spatial_direction.to_string d
;;

let of_string s =
  match Logical_direction.of_string s with
  | Some d -> Some (Logical d)
  | None ->
    (match Spatial_direction.of_string s with
     | Some d -> Some (Spatial d)
     | None -> None)
;;
