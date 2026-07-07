open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { app_id : string option
  ; title : string option
  }
[@@deriving yojson]

let equal { app_id = a_app_id; title = a_title } { app_id = b_app_id; title = b_title } =
  Option.equal String.equal a_app_id b_app_id && Option.equal String.equal a_title b_title
;;
