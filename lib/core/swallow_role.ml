type t =
  | Auto [@name "auto"]
  | Terminal [@name "terminal"]
  | Disabled [@name "disabled"]
[@@deriving yojson]

let all = [ Auto; Terminal; Disabled ]

let to_string = function
  | Auto -> "auto"
  | Terminal -> "terminal"
  | Disabled -> "disabled"
;;
