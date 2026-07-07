open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Trigger of Action.t [@name "trigger"]
  | Setting of Setting.t [@name "setting"]
  | Query of Query.t [@name "query"]
[@@deriving yojson]
