open! Ppx_yojson_conv_lib.Yojson_conv

module Window = struct
  type t =
    | Close [@name "close"]
    | Focus_logical of Ocdwm_core.Direction.Logical.t [@name "focus_logical"]
    | Focus_spatial of Ocdwm_core.Direction.Spatial.t [@name "focus_spatial"]
    | Focus_query of
        { query : Ocdwm_core.Window_query.t
        ; cycle : bool
        } [@name "focus_query"]
    | Tag_query of
        { query : Ocdwm_core.Window_query.t
        ; tags : Ocdwm_core.Tag.Arg.t
        } [@name "tag_query"]
    | Tag_shift of Ocdwm_core.Direction.Logical.t [@name "tag_shift"]
    | Tag_shift_occupied of Ocdwm_core.Direction.Logical.t [@name "tag_shift_occupied"]
    | Move_drag [@name "move_drag"]
    | Move_to of
        { x : Ocdwm_core.Extent.t
        ; y : Ocdwm_core.Extent.t
        } [@name "move_to"]
    | Move_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; by : Ocdwm_core.Extent.t
        } [@name "move_spatial"]
    | Resize_drag [@name "resize_drag"]
    | Resize_to of
        { w : Ocdwm_core.Extent.t
        ; h : Ocdwm_core.Extent.t
        } [@name "resize_to"]
    | Resize_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; by : Ocdwm_core.Extent.t
        } [@name "resize_spatial"]
    | Send_logical of
        { dir : Ocdwm_core.Direction.Logical.t
        ; policy : Ocdwm_core.Tag.Policy.t
        } [@name "send_logical"]
    | Send_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; policy : Ocdwm_core.Tag.Policy.t
        } [@name "send_spatial"]
    | Send_name of
        { name : string
        ; policy : Ocdwm_core.Tag.Policy.t
        } [@name "send_name"]
    | Shift of Ocdwm_core.Direction.Logical.t [@name "shift"]
    | Tag of Ocdwm_core.Tag.Arg.t [@name "tag"]
    | Toggle_tag of Ocdwm_core.Tag.Set.t [@name "toggle_tag"]
    | Toggle_floating [@name "toggle_floating"]
    | Toggle_maximize [@name "toggle_maximize"]
    | Toggle_fullscreen [@name "toggle_fullscreen"]
    | Toggle_fake_fullscreen [@name "toggle_fake_fullscreen"]
    | Zoom [@name "zoom"]
  [@@deriving yojson]
end

module Tag = struct
  type t =
    | View of Ocdwm_core.Tag.Arg.t [@name "view"]
    | Toggle_view of Ocdwm_core.Tag.Set.t [@name "toggle_view"]
    | View_previous [@name "view_previous"]
    | View_cycle of Ocdwm_core.Direction.Logical.t [@name "view_cycle"]
    | View_cycle_occupied of Ocdwm_core.Direction.Logical.t [@name "view_cycle_occupied"]
  [@@deriving yojson]
end

module Layout = struct
  type t = Cycle of Ocdwm_core.Direction.Logical.t [@name "cycle"] [@@deriving yojson]
end

module Output = struct
  type t =
    | Focus_logical of Ocdwm_core.Direction.Logical.t [@name "focus_logical"]
    | Focus_spatial of Ocdwm_core.Direction.Spatial.t [@name "focus_spatial"]
    | Focus_name of string [@name "focus_name"]
    | Toggle_overview [@name "toggle_overview"]
    | Arrangement of Ocdwm_core.Arrangement.t [@name "arrangement"]
  [@@deriving yojson]
end

module Set = struct
  type t =
    | Layout of string [@name "layout"]
    | Mfact of float Ocdwm_core.Delta.t [@name "mfact"]
    | Nmaster of int Ocdwm_core.Delta.t [@name "nmaster"]
    | Gaps_inner of int Ocdwm_core.Delta.t [@name "gaps_inner"]
    | Gaps_outer of int Ocdwm_core.Delta.t [@name "gaps_outer"]
    | Stack of Ocdwm_core.Stack_kind.t [@name "stack"]
    | Dir of Ocdwm_core.Direction.Spatial.t [@name "dir"]
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
        { which : Ocdwm_core.Border_target.t
        ; color : Ocdwm_core.Color.t
        } [@name "border_color"]
  [@@deriving yojson]
end

module Rule = struct
  type t =
    | Add of Ocdwm_core.Rule.t [@name "add"]
    | Remove of Ocdwm_core.Rule.t [@name "remove"]
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
