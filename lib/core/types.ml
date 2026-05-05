(* ocdwm core types - shared type definitions *)

module Rect = struct
  type 'a t =
    { x : 'a
    ; y : 'a
    ; w : 'a
    ; h : 'a
    }
end

module Direction = struct
  type t =
    | Dir_next
    | Dir_prev
    | Dir_left
    | Dir_right
    | Dir_up
    | Dir_down
end

module Delta = struct
  type 'a t =
    | Abs of 'a
    | Rel of 'a
end

module Stack_kind = struct
  type t =
    | Stack_even
    | Stack_diminish
    | Stack_dwindle
end

module Action = struct
  type t =
    | No_action
    (* Process control *)
    | Spawn of string
    | Exit_wm
    (* Window operations *)
    | Close_focused
    | Toggle_floating
    | Toggle_maximize
    | Toggle_fullscreen
    | Move_interactive
    | Resize_interactive
    | Send_to_output of Direction.t (* keep own tags *)
    | Send_to_output_tags of Direction.t (* take dest tags *)
    (* Focus *)
    | Focus_window of Direction.t
    | Focus_output of Direction.t
    (* Stack manipulation *)
    | Swap_window of Direction.t
    | Zoom
    (* Tags *)
    | Tag_view of int
    | Tag_view_mask of Tag_set.t
    | Tag_toggle_view of int
    | Tag_view_previous
    | Tag_view_cycle of Direction.t
    | Window_tag of int
    | Window_toggle_tag of int
    | Window_tag_mask of Tag_set.t
    (* Layout *)
    | Layout_set of string
    | Layout_cycle of Direction.t
    | Set_mfact of float Delta.t
    | Set_nmaster of int Delta.t
    | Set_gaps_inner of int Delta.t
    | Set_gaps_outer of int Delta.t
    | Set_stack of Stack_kind.t
end
