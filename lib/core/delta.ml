type 'a t =
  | Abs of 'a [@name "abs"]
  | Rel of 'a [@name "rel"]
[@@deriving yojson]
