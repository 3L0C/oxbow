open! Ppx_yojson_conv_lib.Yojson_conv

module Window = struct
  type t =
    | Focused [@name "focused"]
    | Matching of
        { wmatch : Window_match.t
        ; all : bool
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
