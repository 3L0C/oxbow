open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Set_tags of Tag_arg.t [@name "set_tags"]
  | Send_to_output of
      { name : string
      ; policy : Tag_policy.t
      } [@name "send_to_output"]
  | Float [@name "float"]
  | Tile [@name "tile"]
  | Fullscreen [@name "fullscreen"]
  | Windowed [@name "windowed"]
[@@deriving yojson]
