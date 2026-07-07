open! Ppx_yojson_conv_lib.Yojson_conv

module Json = struct
  type t = Yojson.Safe.t

  let yojson_of_t = Fun.id
  let t_of_yojson = Fun.id
end

type t =
  { ok : bool
  ; err : string option [@yojson.option]
  ; data : Json.t option [@yojson.option]
  }
[@@deriving yojson]
