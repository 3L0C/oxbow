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
  | Toggle_fullscreen [@name "toggle_fullscreen"]
  | Move_interactive [@name "move_interactive"]
  | Resize_interactive [@name "resize_interactive"]
  | Send_to_output of Direction.t (* keep own tags *) [@name "send_to_output"]
  | Send_to_output_tags of Direction.t (* take dest tags *) [@name "send_to_output_tags"]
  (* Focus *)
  | Focus_window of Direction.t [@name "focus_window"]
  | Focus_output of Direction.t [@name "focus_output"]
  (* Stack manipulation *)
  | Rotate_window of Direction.t [@name "rotate_window"]
  | Zoom [@name "zoom"]
  (* Tags *)
  | Tag_view of Tag_arg.t [@name "tag_view"]
  | Tag_toggle_view of Tag_set.t [@name "tag_toggle_view"]
  | Tag_view_previous [@name "tag_view_previous"]
  | Tag_view_cycle of Direction.t [@name "tag_view_cycle"]
  | Window_tag of Tag_arg.t [@name "window_tag"]
  | Window_toggle_tag of Tag_set.t [@name "window_toggle_tag"]
  (* Layout *)
  | Layout_set of string [@name "layout_set"]
  | Layout_cycle of Direction.t [@name "layout_cycle"]
  | Set_mfact of float Delta.t [@name "set_mfact"]
  | Set_nmaster of int Delta.t [@name "set_nmaster"]
  | Set_gaps_inner of int Delta.t [@name "set_gaps_inner"]
  | Set_gaps_outer of int Delta.t [@name "set_gaps_outer"]
  | Set_stack of Stack_kind.t [@name "set_stack"]
[@@deriving yojson]
