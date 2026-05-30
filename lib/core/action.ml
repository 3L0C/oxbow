open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  (* Process control *)
  | Spawn of string [@name "spawn"]
  | Exit_session [@name "exit_session"]
  | Close_wm [@name "close_wm"]
  (* Window operations *)
  | Close_focused [@name "close_focused"]
  | Toggle_floating [@name "toggle_floating"]
  | Toggle_maximize [@name "toggle_maximize"]
  | Toggle_fake_fullscreen [@name "toggle_fake_fullscreen"]
  | Toggle_fullscreen [@name "toggle_fullscreen"]
  | Move_interactive [@name "move_interactive"]
  | Resize_interactive [@name "resize_interactive"]
  | Move_to of
      { x : Extent.t
      ; y : Extent.t
      } [@name "move_to"]
  | Move_spatial of
      { dir : Spatial_direction.t
      ; by : Extent.t
      } [@name "move_spatial"]
  | Resize_to of
      { w : Extent.t
      ; h : Extent.t
      } [@name "resize_to"]
  | Resize_spatial of
      { dir : Spatial_direction.t
      ; by : Extent.t
      } [@name "resize_spatial"]
  | Send_to_output_logical of
      { dir : Logical_direction.t
      ; policy : Tag_policy.t
      } [@name "send_to_output_logical"]
  | Send_to_output_spatial of
      { dir : Spatial_direction.t
      ; policy : Tag_policy.t
      } [@name "send_to_output_spatial"]
  | Send_to_output_name of
      { name : string
      ; policy : Tag_policy.t
      } [@name "send_to_output_name"]
  (* Focus *)
  | Focus_window_logical of Logical_direction.t [@name "focus_window_logical"]
  | Focus_window_spatial of Spatial_direction.t [@name "focus_window_spatial"]
  | Focus_window_query of Window_query.t [@name "focus_window_query"]
  | Focus_output_logical of Logical_direction.t [@name "focus_output_logical"]
  | Focus_output_spatial of Spatial_direction.t [@name "focus_output_spatial"]
  | Focus_output_name of string [@name "focus_output_name"]
  (* Stack manipulation *)
  | Shift of Logical_direction.t [@name "shift"]
  | Zoom [@name "zoom"]
  (* Tags *)
  | Tag_view of Tag_arg.t [@name "tag_view"]
  | Tag_toggle_view of Tag_set.t [@name "tag_toggle_view"]
  | Tag_view_previous [@name "tag_view_previous"]
  | Tag_view_cycle of Logical_direction.t [@name "tag_view_cycle"]
  | Tag_view_cycle_occupied of Logical_direction.t [@name "tag_view_cycle_occupied"]
  | Window_tag of Tag_arg.t [@name "window_tag"]
  | Window_toggle_tag of Tag_set.t [@name "window_toggle_tag"]
  (* Layout *)
  | Layout_set of string [@name "layout_set"]
  | Layout_cycle of Logical_direction.t [@name "layout_cycle"]
  | Set_mfact of float Delta.t [@name "set_mfact"]
  | Set_nmaster of int Delta.t [@name "set_nmaster"]
  | Set_gaps_inner of int Delta.t [@name "set_gaps_inner"]
  | Set_gaps_outer of int Delta.t [@name "set_gaps_outer"]
  | Set_stack of Stack_kind.t [@name "set_stack"]
  (* Config settings *)
  | Set_focus_follows_pointer of bool [@name "set_focus_follows_pointer"]
  | Toggle_focus_follows_pointer [@name "toggle_focus_follows_pointer"]
[@@deriving yojson]
