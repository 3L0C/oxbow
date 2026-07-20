open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core

module Window_info = struct
  type t =
    { id : int
    ; identifier : string option
    ; title : string option
    ; app_id : string option
    ; output : string option
    ; tags : int list
    ; focused : bool
    ; urgent : bool
    ; hidden : bool
    ; presentation : string
    }
  [@@deriving yojson]
end

type t =
  | Rules [@name "rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
  | Outputs [@name "outputs"]
  | Focused [@name "focused"]
  | Windows of { query : Window_query.t option } [@name "windows"]
[@@deriving yojson]
