type 'a t =
  | Abs of 'a [@name "abs"]
  | Rel of 'a [@name "rel"]
[@@deriving yojson]

let resolve ~add ~current = function
  | Abs a -> a
  | Rel r -> add current r
;;
