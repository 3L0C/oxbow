open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core

module Border = struct
  type t =
    | Width of int32 [@name "width"]
    | Color of
        { which : Border_target.t
        ; color : Color.t
        } [@name "color"]
  [@@deriving yojson]
end

module Gaps = struct
  type t =
    | Inner of
        { delta : int Delta.t
        ; global : bool
        } [@name "inner"]
    | Outer of
        { delta : int Delta.t
        ; global : bool
        } [@name "outer"]
  [@@deriving yojson]
end

module Input = struct
  module Cursor = struct
    type t =
      | Theme of
          { name : string
          ; size : int32
          } [@name "theme"]
    [@@deriving yojson]
  end

  module Keyboard = struct
    type t =
      | Repeat of
          { rate : int
          ; delay : int
          } [@name "repeat"]
      | Layout_file of string [@name "layout_file"]
    [@@deriving yojson]
  end

  module Pointer = struct
    type t =
      | Follow of bool [@name "follow"]
      | Toggle_follow [@name "toggle_follow"]
      | Warp of bool [@name "warp"]
      | Toggle_warp [@name "toggle_warp"]
    [@@deriving yojson]
  end

  type t =
    | Cursor of Cursor.t [@name "cursor"]
    | Keyboard of Keyboard.t [@name "keyboard"]
    | Pointer of Pointer.t [@name "pointer"]
  [@@deriving yojson]
end

module Keymap = struct
  module Mode = struct
    type t =
      | Declare of string [@name "declare"]
      | Enter of string [@name "enter"]
    [@@deriving yojson]
  end

  type t = Mode of Mode.t [@name "mode"] [@@deriving yojson]
end

module Layout = struct
  module Scrolling = struct
    type t =
      | Column_width of
          { delta : float Delta.t
          ; global : bool
          } [@name "column_width"]
      | Policy of
          { policy : Scroll_policy.t
          ; global : bool
          } [@name "policy"]
    [@@deriving yojson]
  end

  module Tiling = struct
    type t =
      | Cycle of Direction.Logical.t [@name "cycle"]
      | Mfact of
          { delta : float Delta.t
          ; global : bool
          } [@name "mfact"]
      | Nmaster of
          { delta : int Delta.t
          ; global : bool
          } [@name "nmaster"]
      | Orientation of
          { dir : Direction.Spatial.t
          ; global : bool
          } [@name "orientation"]
      | Scheme of
          { scheme : Ocdwm_core.Scheme.t
          ; global : bool
          } [@name "scheme"]
    [@@deriving yojson]
  end

  type t =
    | Cycle of Direction.Logical.t [@name "cycle"]
    | Select of
        { layout : Ocdwm_core.Layout.t
        ; global : bool
        } [@name "select"]
    | Scrolling of Scrolling.t [@name "scrolling"]
    | Tiling of Tiling.t [@name "tiling"]
  [@@deriving yojson]
end

module Output = struct
  module Swap = struct
    module Target = struct
      type t =
        | Pair of
            { first : string option [@yojson.option]
            ; second : string option [@yojson.option]
            } [@name "pair"]
        | Ring of
            { members : string list
            ; rev : bool
            } [@name "ring"]
      [@@deriving yojson]
    end

    type t =
      | Tags of
          { target : Target.t
          ; policy : Ocdwm_core.Tag.Policy.t
          ; follow : bool
          } [@name "swap_tags"]
      | All of
          { target : Target.t
          ; policy : Ocdwm_core.Tag.Policy.t
          ; follow : bool
          } [@name "swap_all"]
      | Visible of
          { target : Target.t
          ; policy : Ocdwm_core.Tag.Policy.t
          ; follow : bool
          } [@name "swap_visible"]
    [@@deriving yojson]
  end

  type t =
    | Column_width of float Delta.t [@name "column_width"]
    | Focus_logical of
        { dir : Direction.Logical.t
        ; warp : bool option [@yojson.option]
        } [@name "focus_logical"]
    | Focus_spatial of
        { dir : Direction.Spatial.t
        ; warp : bool option [@yojson.option]
        } [@name "focus_spatial"]
    | Focus_name of
        { name : string
        ; warp : bool option [@yojson.option]
        } [@name "focus_name"]
    | Toggle_overview [@name "toggle_overview"]
    | Swap of Swap.t [@name "swap"]
  [@@deriving yojson]
end

module Rule = struct
  type t =
    | Add of Rule.t [@name "add"]
    | Remove of Rule.t [@name "remove"]
  [@@deriving yojson]
end

module Session = struct
  type t = Exit [@name "exit"] [@@deriving yojson]
end

module Tag = struct
  type t =
    | View of Tag.Arg.t [@name "view"]
    | Toggle_view of Tag.Set.t [@name "toggle_view"]
    | View_previous [@name "view_previous"]
    | View_cycle of Direction.Logical.t [@name "view_cycle"]
    | View_cycle_occupied of Direction.Logical.t [@name "view_cycle_occupied"]
  [@@deriving yojson]
end

module Window = struct
  type t =
    | Close [@name "close"]
    | Focus_logical of
        { dir : Direction.Logical.t
        ; warp : bool option [@yojson.option]
        } [@name "focus_logical"]
    | Focus_spatial of
        { dir : Direction.Spatial.t
        ; warp : bool option [@yojson.option]
        } [@name "focus_spatial"]
    | Focus_query of
        { query : Window_query.t
        ; cycle : bool
        ; warp : bool option [@yojson.option]
        } [@name "focus_query"]
    | Tag of
        { tags : Ocdwm_core.Tag.Arg.t
        ; follow : bool
        } [@name "tag"]
    | Tag_shift of
        { dir : Direction.Logical.t
        ; follow : bool
        } [@name "tag_shift"]
    | Tag_shift_occupied of
        { dir : Direction.Logical.t
        ; follow : bool
        } [@name "tag_shift_occupied"]
    | Tag_query of
        { query : Window_query.t
        ; tags : Ocdwm_core.Tag.Arg.t
        } [@name "tag_query"]
    | Move_drag [@name "move_drag"]
    | Move_to of
        { x : Extent.t
        ; y : Extent.t
        } [@name "move_to"]
    | Move_spatial of
        { dir : Direction.Spatial.t
        ; by : Extent.t
        } [@name "move_spatial"]
    | Resize_drag [@name "resize_drag"]
    | Resize_to of
        { w : Extent.t
        ; h : Extent.t
        } [@name "resize_to"]
    | Resize_spatial of
        { dir : Direction.Spatial.t
        ; by : Extent.t
        } [@name "resize_spatial"]
    | Send_logical of
        { dir : Direction.Logical.t
        ; policy : Ocdwm_core.Tag.Policy.t
        ; follow : bool
        } [@name "send_logical"]
    | Send_spatial of
        { dir : Direction.Spatial.t
        ; policy : Ocdwm_core.Tag.Policy.t
        ; follow : bool
        } [@name "send_spatial"]
    | Send_name of
        { name : string
        ; policy : Ocdwm_core.Tag.Policy.t
        ; follow : bool
        } [@name "send_name"]
    | Shift of Direction.Logical.t [@name "shift"]
    | Toggle_tag of Ocdwm_core.Tag.Set.t [@name "toggle_tag"]
    | Toggle_floating [@name "toggle_floating"]
    | Toggle_maximize [@name "toggle_maximize"]
    | Toggle_fullscreen [@name "toggle_fullscreen"]
    | Toggle_fake_fullscreen [@name "toggle_fake_fullscreen"]
    | Zoom of { warp : bool option [@yojson.option] } [@name "zoom"]
    | Column_consume [@name "column_consume"]
    | Column_release [@name "column_release"]
    | Column_move of Direction.Logical.t [@name "column_move"]
    | Column_width of float Delta.t [@name "column_width"]
    | Column_width_default [@name "column_width_default"]
    | Column_width_cycle [@name "column_width_cycle"]
  [@@deriving yojson]
end

module Wm = struct
  type t = Close [@name "close"] [@@deriving yojson]
end

type t =
  | Border of Border.t [@name "border"]
  | Exec of string array [@name "exec"]
  | Gaps of Gaps.t [@name "gaps"]
  | Input of Input.t [@name "input"]
  | Keymap of Keymap.t [@name "keymap"]
  | Layout of Layout.t [@name "layout"]
  | Output of Output.t [@name "output"]
  | Rule of Rule.t [@name "rule"]
  | Session of Session.t [@name "session"]
  | Spawn of string [@name "spawn"]
  | Tag of Tag.t [@name "tag"]
  | Window of Window.t [@name "window"]
  | Wm of Wm.t [@name "wm"]
[@@deriving yojson]
