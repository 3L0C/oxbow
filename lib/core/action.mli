type t =
  (* Process control *)
  | Spawn of string
  | Exit_session
  | Close_wm
  (* Window operations *)
  | Close_focused
  | Toggle_floating
  | Toggle_maximize
  | Toggle_fake_fullscreen
  | Toggle_fullscreen
  | Move_interactive
  | Resize_interactive
  | Move_to of
      { x : Extent.t
      ; y : Extent.t
      }
  | Move_spatial of
      { dir : Direction.Spatial.t
      ; by : Extent.t
      }
  | Resize_to of
      { w : Extent.t
      ; h : Extent.t
      }
  | Resize_spatial of
      { dir : Direction.Spatial.t
      ; by : Extent.t
      }
  | Send_to_output_logical of
      { dir : Direction.Logical.t
      ; policy : Tag.Policy.t
      }
  | Send_to_output_spatial of
      { dir : Direction.Spatial.t
      ; policy : Tag.Policy.t
      }
  | Send_to_output_name of
      { name : string
      ; policy : Tag.Policy.t
      }
  (* Focus *)
  | Focus_window_logical of Direction.Logical.t
  | Focus_window_spatial of Direction.Spatial.t
  | Focus_window_query of Window_query.t
  | Focus_output_logical of Direction.Logical.t
  | Focus_output_spatial of Direction.Spatial.t
  | Focus_output_name of string
  (* Stack manipulation *)
  | Shift of Direction.Logical.t
  | Zoom
  (* Tags *)
  | Tag_view of Tag.Arg.t
  | Tag_toggle_view of Tag.Set.t
  | Tag_view_previous
  | Tag_view_cycle of Direction.Logical.t
  | Tag_view_cycle_occupied of Direction.Logical.t
  | Window_tag of Tag.Arg.t
  | Window_toggle_tag of Tag.Set.t
  (* Layout *)
  | Layout_set of string
  | Layout_cycle of Direction.Logical.t
  | Set_mfact of float Delta.t
  | Set_nmaster of int Delta.t
  | Set_gaps_inner of int Delta.t
  | Set_gaps_outer of int Delta.t
  | Set_stack of Stack_kind.t
  (* Config settings *)
  | Set_focus_follows_pointer of bool
  | Toggle_focus_follows_pointer
  | Set_keyboard_repeat of
      { rate : int
      ; delay : int
      }
  | Set_keyboard_layout_file of string
  | Set_warp_on_focus of bool
  | Toggle_warp_on_focus
  | Set_cursor_theme of
      { name : string
      ; size : int
      }
  | Set_border_width of int32
  | Set_border_color of
      { which : Border_target.t
      ; color : int32
      }
  | Add_rule of Rule.t
  | Remove_rule of Rule.t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
