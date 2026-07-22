module Window : sig
  type t =
    | Close
    | Focus_logical of
        { dir : Ocdwm_core.Direction.Logical.t
        ; warp : bool option
        }
    | Focus_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; warp : bool option
        }
    | Focus_query of
        { query : Ocdwm_core.Window_query.t
        ; cycle : bool
        ; warp : bool option
        }
    | Tag_query of
        { query : Ocdwm_core.Window_query.t
        ; tags : Ocdwm_core.Tag.Arg.t
        }
    | Tag_shift of Ocdwm_core.Direction.Logical.t
    | Tag_shift_occupied of Ocdwm_core.Direction.Logical.t
    | Move_drag
    | Move_to of
        { x : Ocdwm_core.Extent.t
        ; y : Ocdwm_core.Extent.t
        }
    | Move_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; by : Ocdwm_core.Extent.t
        }
    | Resize_drag
    | Resize_to of
        { w : Ocdwm_core.Extent.t
        ; h : Ocdwm_core.Extent.t
        }
    | Resize_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; by : Ocdwm_core.Extent.t
        }
    | Send_logical of
        { dir : Ocdwm_core.Direction.Logical.t
        ; policy : Ocdwm_core.Tag.Policy.t
        }
    | Send_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; policy : Ocdwm_core.Tag.Policy.t
        }
    | Send_name of
        { name : string
        ; policy : Ocdwm_core.Tag.Policy.t
        }
    | Shift of Ocdwm_core.Direction.Logical.t
    | Tag of Ocdwm_core.Tag.Arg.t
    | Toggle_tag of Ocdwm_core.Tag.Set.t
    | Toggle_floating
    | Toggle_maximize
    | Toggle_fullscreen
    | Toggle_fake_fullscreen
    | Zoom of { warp : bool option }
    | Column_consume
    | Column_release
    | Column_move of Ocdwm_core.Direction.Logical.t
    | Column_width of float Ocdwm_core.Delta.t
    | Column_width_default
    | Column_width_cycle

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Tag : sig
  type t =
    | View of Ocdwm_core.Tag.Arg.t
    | Toggle_view of Ocdwm_core.Tag.Set.t
    | View_previous
    | View_cycle of Ocdwm_core.Direction.Logical.t
    | View_cycle_occupied of Ocdwm_core.Direction.Logical.t

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Layout : sig
  type t = Cycle of Ocdwm_core.Direction.Logical.t

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Output : sig
  type t =
    | Focus_logical of
        { dir : Ocdwm_core.Direction.Logical.t
        ; warp : bool option
        }
    | Focus_spatial of
        { dir : Ocdwm_core.Direction.Spatial.t
        ; warp : bool option
        }
    | Focus_name of
        { name : string
        ; warp : bool option
        }
    | Toggle_overview

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Set : sig
  type t =
    | Scheme of Ocdwm_core.Scheme.t
    | Layout of Ocdwm_core.Layout.t
    | Mfact of float Ocdwm_core.Delta.t
    | Nmaster of int Ocdwm_core.Delta.t
    | Gaps_inner of int Ocdwm_core.Delta.t
    | Gaps_outer of int Ocdwm_core.Delta.t
    | Stack of Ocdwm_core.Stack_kind.t
    | Scroll_policy of Ocdwm_core.Scroll_policy.t
    | Default_width of float Ocdwm_core.Delta.t
    | Dir of Ocdwm_core.Direction.Spatial.t
    | Focus_follows_pointer of bool
    | Toggle_focus_follows_pointer
    | Keyboard_repeat of
        { rate : int
        ; delay : int
        }
    | Keyboard_layout_file of string
    | Pointer_warp of bool
    | Toggle_pointer_warp
    | Cursor_theme of
        { name : string
        ; size : int32
        }
    | Border_width of int32
    | Border_color of
        { which : Ocdwm_core.Border_target.t
        ; color : Ocdwm_core.Color.t
        }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Rule : sig
  type t =
    | Add of Ocdwm_core.Rule.t
    | Remove of Ocdwm_core.Rule.t

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Mode : sig
  type t =
    | Declare of string
    | Enter of string

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Session : sig
  type t = Exit

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Wm : sig
  type t = Close

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Execute : sig
  type t =
    | Spawn of string
    | Exec of string array

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Window of Window.t
  | Tag of Tag.t
  | Layout of Layout.t
  | Output of Output.t
  | Set of Set.t
  | Rule of Rule.t
  | Mode of Mode.t
  | Session of Session.t
  | Wm of Wm.t
  | Execute of Execute.t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
