open! Ppx_yojson_conv_lib.Yojson_conv

module Body = struct
  type t =
    | Command of Command.t [@name "command"]
    | Keymap of Keymap.t [@name "keymap"]
    | Query of Query.t [@name "query"]
  [@@deriving yojson]
end

type t =
  { body : Body.t
  ; seat : string option [@yojson.option]
  }
[@@deriving yojson]
