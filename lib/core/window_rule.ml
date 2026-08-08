open! Ppx_yojson_conv_lib.Yojson_conv

module Effects = struct
  module Output = struct
    type t =
      { name : string
      ; policy : Tag.Policy.t
      }
    [@@deriving yojson]
  end

  module Presentation = struct
    type t =
      | Float [@name "float"]
      | Tile [@name "tile"]
      | Fullscreen [@name "fullscreen"]
      | Windowed [@name "windowed"]
      | Maximize [@name "maximize"]
      | Fake_fullscreen [@name "fake_fullscreen"]
    [@@deriving yojson]
  end

  module Resize_to = struct
    type t =
      { w : Extent.t
      ; h : Extent.t
      }
    [@@deriving yojson]
  end

  module Move_to = struct
    type t =
      { x : Extent.t
      ; y : Extent.t
      }
    [@@deriving yojson]
  end

  type t =
    { output : Output.t option [@yojson.option]
    ; tags : Tag.Arg.t option [@yojson.option]
    ; presentation : Presentation.t option [@yojson.option]
    ; resize_to : Resize_to.t option [@yojson.option]
    ; move_to : Move_to.t option [@yojson.option]
    ; sticky : Sticky.t option [@yojson.option]
    ; swallow : Swallow_role.t option [@yojson.option]
    ; label_as : string option [@yojson.option]
    }
  [@@deriving yojson]

  let merge = Json_slots.merge yojson_of_t t_of_yojson
  let is_empty = Json_slots.is_empty yojson_of_t
end

type t =
  { pattern : Window_pattern.t
  ; effects : Effects.t
  }
[@@deriving yojson]
