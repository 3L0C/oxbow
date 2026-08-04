open! Ppx_yojson_conv_lib.Yojson_conv
open! Oxbow_core

module Reply = struct
  module Available = struct
    type t = { available : string list } [@@deriving yojson]
  end

  module Seats = struct
    type t =
      { name : string
      ; mode : string
      ; output : string option [@yojson.option]
      }
    [@@deriving yojson]
  end

  module Input_device = struct
    type t =
      { name : string
      ; role : string
      }
    [@@deriving yojson]
  end
end

type t =
  | Focused [@name "focused"]
  | Input_devices of
      { pattern : string option [@yojson.option]
      ; case : Pattern.Case.t
      ; role : Input.Role.t option [@yojson.option]
      } [@name "input_devices"]
  | Input_rules [@name "input_rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
  | Layouts of { output : string option [@yojson.option] } [@name "layouts"]
  | Outputs [@name "outputs"]
  | Schemes of { output : string option [@yojson.option] } [@name "schemes"]
  | Seats
  | Tags of { output : string option [@yojson.option] } [@name "tags"]
  | Window_rules [@name "window_rules"]
  | Windows of { filter : Window_match.t } [@name "windows"]
[@@deriving yojson]
