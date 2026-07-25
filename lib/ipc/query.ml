open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core

module Reply = struct
  module Layouts = struct
    type t = { available : string list } [@@deriving yojson]
  end

  module Schemes = struct
    type t = { available : string list } [@@deriving yojson]
  end

  module Seats = struct
    type t =
      { name : string
      ; mode : string
      ; output : string option
      }
    [@@deriving yojson]
  end
end

type t =
  | Rules [@name "rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
  | Outputs [@name "outputs"]
  | Focused [@name "focused"]
  | Windows of { filter : Window_match.t } [@name "windows"]
  | Tags of { output : string option } [@name "tags"]
  | Layouts of { output : string option } [@name "layouts"]
  | Schemes of { output : string option } [@name "schemes"]
  | Seats
[@@deriving yojson]
