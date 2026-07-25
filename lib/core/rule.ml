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
    }
  [@@deriving yojson]

  let merge ~old ~new_ =
    let slot old_slot = function
      | None -> old_slot
      | Some slot -> Some slot
    in
    { output = slot old.output new_.output
    ; tags = slot old.tags new_.tags
    ; presentation = slot old.presentation new_.presentation
    ; resize_to = slot old.resize_to new_.resize_to
    ; move_to = slot old.move_to new_.move_to
    }
  ;;

  let is_empty e =
    e.output = None
    && e.tags = None
    && e.presentation = None
    && e.resize_to = None
    && e.move_to = None
  ;;
end

type t =
  { pattern : Pattern.t
  ; effects : Effects.t
  }
[@@deriving yojson]
