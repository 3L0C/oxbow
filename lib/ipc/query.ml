open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core

module Layouts_reply = struct
  type t =
    { available : string list
    ; current : Record.Layout.t list
    }
  [@@deriving yojson]
end

module Seat_info = struct
  type t =
    { name : string
    ; mode : string
    ; output : string option
    }
  [@@deriving yojson]
end

type t =
  | Rules [@name "rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
  | Outputs [@name "outputs"]
  | Focused [@name "focused"]
  | Windows of { query : Window_query.t option } [@name "windows"]
  | Tags of { output : string option } [@name "tags"]
  | Layouts of { output : string option } [@name "layouts"]
  | Seats
[@@deriving yojson]
