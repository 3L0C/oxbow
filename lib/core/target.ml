open! Ppx_yojson_conv_lib.Yojson_conv

module Select = struct
  type t =
    | Best [@name "best"]
    | All [@name "all"]
    | Cycle [@name "cycle"]
  [@@deriving yojson]

  let all = [ Best; All; Cycle ]

  let to_string = function
    | Best -> "best"
    | All -> "all"
    | Cycle -> "cycle"
  ;;
end

module Window = struct
  type t =
    | Focused [@name "focused"]
    | Matching of
        { wmatch : Window_match.t
        ; select : Select.t
        } [@name "matching"]
  [@@deriving yojson]
end

module Output = struct
  type t =
    | Focused [@name "focused"]
    | Matching of string [@name "matching"]
  [@@deriving yojson]
end

type t =
  | Window of Window.t [@name "window"]
  | Output of Output.t [@name "output"]
[@@deriving yojson]
