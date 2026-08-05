module Toggle = struct
  type t =
    | Occupied [@name "occupied"]
    | All [@name "all"]
  [@@deriving yojson]

  let all = [ Occupied; All ]

  let to_string = function
    | Occupied -> "occupied"
    | All -> "all"
  ;;
end

type t =
  | Off [@name "off"]
  | Occupied [@name "occupied"]
  | All [@name "all"]
[@@deriving yojson]

let all = [ Off; Occupied; All ]

let to_string = function
  | Off -> "off"
  | Occupied -> "occupied"
  | All -> "all"
;;

let of_toggle toggle =
  match toggle with
  | Toggle.Occupied -> Occupied
  | Toggle.All -> All
;;
