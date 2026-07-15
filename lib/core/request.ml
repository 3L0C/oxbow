open! Ppx_yojson_conv_lib.Yojson_conv

module Body = struct
  type t =
    | Trigger of Action.t [@name "trigger"]
    | Setting of Setting.t [@name "setting"]
    | Query of Query.t [@name "query"]
  [@@deriving yojson]
end

type t =
  { body : Body.t
  ; seat : string option [@yojson.option]
  }
[@@deriving yojson]
