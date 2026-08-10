open! Ppx_yojson_conv_lib.Yojson_conv
open! Oxbow_core

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
        ; scope : Scope.t
        } [@name "inner"]
    | Outer of
        { delta : int Delta.t
        ; scope : Scope.t
        } [@name "outer"]
    | Overview of
        { delta : int Delta.t
        ; scope : Scope.t
        } [@name "overview"]
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
      | Follow of Focus_follows_policy.t [@name "follow"]
      | Cycle_follow [@name "cycle_follow"]
      | Warp of bool [@name "warp"]
      | Toggle_warp [@name "toggle_warp"]
    [@@deriving yojson]
  end

  type t =
    | Cursor of Cursor.t [@name "cursor"]
    | Keyboard of Keyboard.t [@name "keyboard"]
    | Pointer of Pointer.t [@name "pointer"]
    | Rule_add of Input_rule.t [@name "rule_add"]
    | Rule_remove of int [@name "rule_remove"]
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
      | Select of
          { align : Align.t
          ; scope : Scope.t
          } [@name "select"]
      | Align of
          { align : Align.t
          ; scope : Scope.t
          } [@name "align"]
      | Default_width of
          { delta : float Delta.t
          ; scope : Scope.t
          } [@name "default_width"]
      | Orientation of
          { dir : Direction.Spatial.t
          ; scope : Scope.t
          } [@name "orientation"]
    [@@deriving yojson]
  end

  module Tiling = struct
    type t =
      | Cycle of Direction.Logical.t [@name "cycle"]
      | Mfact of
          { delta : float Delta.t
          ; scope : Scope.t
          } [@name "mfact"]
      | Nmaster of
          { delta : int Delta.t
          ; scope : Scope.t
          } [@name "nmaster"]
      | Orientation of
          { dir : Direction.Spatial.t
          ; scope : Scope.t
          } [@name "orientation"]
      | Select of
          { scheme : Scheme.t
          ; scope : Scope.t
          } [@name "select"]
      | Scheme of
          { scheme : Scheme.t
          ; scope : Scope.t
          } [@name "scheme"]
    [@@deriving yojson]
  end

  type t =
    | Cycle of Direction.Logical.t [@name "cycle"]
    | Select of
        { layout : Layout.t
        ; scope : Scope.t
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
          ; policy : Tag.Policy.t
          ; follow : bool
          } [@name "swap_tags"]
      | All of
          { target : Target.t
          ; policy : Tag.Policy.t
          ; follow : bool
          } [@name "swap_all"]
      | Visible of
          { target : Target.t
          ; policy : Tag.Policy.t
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
    | Focus_match of
        { target : Target.Output.One.t
        ; warp : bool option [@yojson.option]
        } [@name "focus_name"]
    | Toggle_overview [@name "toggle_overview"]
    | Cycle_overview of
        { dir : Direction.Logical.t
        ; until_release : string option
        } [@name "overview_cycle"]
    | Swap of Swap.t [@name "swap"]
    | Label_add of
        { label : string
        ; target : Target.Output.Any.t
        } [@name "label_add"]
    | Label_remove of
        { label : string
        ; target : Target.Output.Any.t
        } [@name "label_remove"]
  [@@deriving yojson]
end

module Scratchpad = struct
  type t = Toggle of string [@name "toggle"] [@@deriving yojson]
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
    | Close of Target.Window.Any.t [@name "close"]
    | Focus_logical of
        { dir : Direction.Logical.t
        ; warp : bool option [@yojson.option]
        ; target : Target.Window.One.t
        } [@name "focus_logical"]
    | Focus_spatial of
        { dir : Direction.Spatial.t
        ; warp : bool option [@yojson.option]
        ; target : Target.Window.One.t
        } [@name "focus_spatial"]
    | Focus_match of
        { warp : bool option [@yojson.option]
        ; target : Target.Window.One.t
        } [@name "focus_match"]
    | Tag of
        { tags : Oxbow_core.Tag.Arg.t
        ; follow : bool
        ; target : Target.Window.Any.t
        } [@name "tag"]
    | Tag_shift of
        { dir : Direction.Logical.t
        ; follow : bool
        ; target : Target.Window.Any.t
        } [@name "tag_shift"]
    | Tag_shift_occupied of
        { dir : Direction.Logical.t
        ; follow : bool
        ; target : Target.Window.Any.t
        } [@name "tag_shift_occupied"]
    | Move_drag [@name "move_drag"]
    | Move_to of
        { x : Extent.t
        ; y : Extent.t
        ; target : Target.Window.Any.t
        } [@name "move_to"]
    | Move_spatial of
        { dir : Direction.Spatial.t
        ; by : Extent.t
        ; target : Target.Window.Any.t
        } [@name "move_spatial"]
    | Resize_drag [@name "resize_drag"]
    | Resize_to of
        { w : Extent.t
        ; h : Extent.t
        ; target : Target.Window.Any.t
        } [@name "resize_to"]
    | Resize_spatial of
        { dir : Direction.Spatial.t
        ; by : Extent.t
        ; target : Target.Window.Any.t
        } [@name "resize_spatial"]
    | Send_logical of
        { dir : Direction.Logical.t
        ; policy : Oxbow_core.Tag.Policy.t
        ; follow : bool
        ; target : Target.Window.Any.t
        } [@name "send_logical"]
    | Send_spatial of
        { dir : Direction.Spatial.t
        ; policy : Oxbow_core.Tag.Policy.t
        ; follow : bool
        ; target : Target.Window.Any.t
        } [@name "send_spatial"]
    | Send_name of
        { name : string
        ; policy : Oxbow_core.Tag.Policy.t
        ; follow : bool
        ; target : Target.Window.Any.t
        } [@name "send_name"]
    | Shift of
        { dir : Direction.Logical.t
        ; target : Target.Window.One.t
        } [@name "shift"]
    | Toggle_tag of
        { tags : Oxbow_core.Tag.Set.t
        ; target : Target.Window.Any.t
        } [@name "toggle_tag"]
    | Toggle_floating of Target.Window.Any.t [@name "toggle_floating"]
    | Toggle_maximize of Target.Window.One.t [@name "toggle_maximize"]
    | Toggle_fullscreen of Target.Window.One.t [@name "toggle_fullscreen"]
    | Toggle_fake_fullscreen of Target.Window.Any.t [@name "toggle_fake_fullscreen"]
    | Set_sticky of
        { scope : Sticky.t
        ; target : Target.Window.Any.t
        } [@name "set_sticky"]
    | Toggle_sticky of
        { toggle : Sticky.Toggle.t
        ; target : Target.Window.Any.t
        } [@name "toggle_sticky"]
    | Toggle_swallow of Target.Window.Any.t [@name "toggle_swallow"]
    | Zoom of
        { warp : bool option [@yojson.option]
        ; target : Target.Window.One.t
        } [@name "zoom"]
    | Column_consume of Target.Window.One.t [@name "column_consume"]
    | Column_release of Target.Window.One.t [@name "column_release"]
    | Column_move of
        { dir : Direction.Logical.t
        ; target : Target.Window.One.t
        } [@name "column_move"]
    | Column_width of
        { delta : float Delta.t
        ; target : Target.Window.One.t
        } [@name "column_width"]
    | Column_width_default of Target.Window.One.t [@name "column_width_default"]
    | Column_width_cycle of Target.Window.One.t [@name "column_width_cycle"]
    | Rule_add of Window_rule.t [@name "rule_add"]
    | Rule_remove of int [@name "rule_remove"]
    | Label_add of
        { label : string
        ; target : Target.Window.Any.t
        } [@name "label_add"]
    | Label_remove of
        { label : string
        ; target : Target.Window.Any.t
        } [@name "label_remove"]
    | Spawn_position of Spawn_position.t [@name "spawn_position"]
    | Spawn_focus of bool [@name "spawn_focus"]
    | Drag_retile of bool [@name "drag_retile"]
    | Scratchpad_set of
        { name : string
        ; target : Target.Window.Any.t
        } [@name "scratchpad_set"]
    | Scratchpad_clear of { target : Target.Window.Any.t } [@name "scratchpad_clear"]
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
  | Scratchpad of Scratchpad.t [@name "scratchpad"]
  | Session of Session.t [@name "session"]
  | Spawn of string [@name "spawn"]
  | Tag of Tag.t [@name "tag"]
  | Window of Window.t [@name "window"]
  | Wm of Wm.t [@name "wm"]
[@@deriving yojson]
