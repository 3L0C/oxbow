open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core

module Window = struct
  type t =
    | Close [@name "close"]
    | Focus_logical of Direction.Logical.t [@name "focus_logical"]
    | Focus_spatial of Direction.Spatial.t [@name "focus_spatial"]
    | Focus_query of
        { query : Window_query.t
        ; cycle : bool
        } [@name "focus_query"]
    | Tag_query of
        { query : Window_query.t
        ; tags : Tag.Arg.t
        } [@name "tag_query"]
    | Tag_shift of Direction.Logical.t [@name "tag_shift"]
    | Tag_shift_occupied of Direction.Logical.t [@name "tag_shift_occupied"]
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
        ; policy : Tag.Policy.t
        } [@name "send_logical"]
    | Send_spatial of
        { dir : Direction.Spatial.t
        ; policy : Tag.Policy.t
        } [@name "send_spatial"]
    | Send_name of
        { name : string
        ; policy : Tag.Policy.t
        } [@name "send_name"]
    | Shift of Direction.Logical.t [@name "shift"]
    | Tag of Tag.Arg.t [@name "tag"]
    | Toggle_tag of Tag.Set.t [@name "toggle_tag"]
    | Toggle_floating [@name "toggle_floating"]
    | Toggle_maximize [@name "toggle_maximize"]
    | Toggle_fullscreen [@name "toggle_fullscreen"]
    | Toggle_fake_fullscreen [@name "toggle_fake_fullscreen"]
    | Zoom [@name "zoom"]
    | Column_consume [@name "column_consume"]
    | Column_release [@name "column_release"]
    | Column_move of Direction.Logical.t [@name "column_move"]
    | Column_width of float Delta.t [@name "column_width"]
    | Column_width_default [@name "column_width_default"]
    | Column_width_cycle [@name "column_width_cycle"]
  [@@deriving yojson]
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

module Layout = struct
  type t = Cycle of Direction.Logical.t [@name "cycle"] [@@deriving yojson]
end

module Output = struct
  type t =
    | Focus_logical of Direction.Logical.t [@name "focus_logical"]
    | Focus_spatial of Direction.Spatial.t [@name "focus_spatial"]
    | Focus_name of string [@name "focus_name"]
    | Toggle_overview [@name "toggle_overview"]
    | Layout of Ocdwm_core.Layout.t [@name "layout"]
  [@@deriving yojson]
end

module Set = struct
  type t =
    | Scheme of Scheme.t [@name "scheme"]
    | Mfact of float Delta.t [@name "mfact"]
    | Nmaster of int Delta.t [@name "nmaster"]
    | Gaps_inner of int Delta.t [@name "gaps_inner"]
    | Gaps_outer of int Delta.t [@name "gaps_outer"]
    | Stack of Stack_kind.t [@name "stack"]
    | Scroll_policy of Scroll_policy.t [@name "scroll_policy"]
    | Default_width of float Delta.t [@name "default_width"]
    | Dir of Direction.Spatial.t [@name "dir"]
    | Focus_follows_pointer of bool [@name "focus_follows_pointer"]
    | Toggle_focus_follows_pointer [@name "toggle_focus_follows_pointer"]
    | Keyboard_repeat of
        { rate : int
        ; delay : int
        } [@name "keyboard_repeat"]
    | Keyboard_layout_file of string [@name "keyboard_layout_file"]
    | Pointer_warp of bool [@name "pointer_warp"]
    | Toggle_pointer_warp [@name "toggle_pointer_warp"]
    | Cursor_theme of
        { name : string
        ; size : int32
        } [@name "cursor_theme"]
    | Border_width of int32 [@name "border_width"]
    | Border_color of
        { which : Border_target.t
        ; color : Color.t
        } [@name "border_color"]
  [@@deriving yojson]
end

module Rule = struct
  type t =
    | Add of Rule.t [@name "add"]
    | Remove of Rule.t [@name "remove"]
  [@@deriving yojson]
end

module Mode = struct
  type t =
    | Declare of string [@name "declare"]
    | Enter of string [@name "enter"]
  [@@deriving yojson]
end

module Session = struct
  type t = Exit [@name "exit"] [@@deriving yojson]
end

module Wm = struct
  type t = Close [@name "close"] [@@deriving yojson]
end

module Execute = struct
  type t =
    | Spawn of string [@name "spawn"]
    | Exec of string array [@name "exec"]
  [@@deriving yojson]
end

type t =
  | Window of Window.t [@name "window"]
  | Tag of Tag.t [@name "tag"]
  | Layout of Layout.t [@name "layout"]
  | Output of Output.t [@name "output"]
  | Set of Set.t [@name "set"]
  | Rule of Rule.t [@name "rule"]
  | Mode of Mode.t [@name "mode"]
  | Session of Session.t [@name "session"]
  | Wm of Wm.t [@name "wm"]
  | Execute of Execute.t [@name "execute"]
[@@deriving yojson]
