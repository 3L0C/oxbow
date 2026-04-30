(* ocdwm ipc types - shared type definitions *)

module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_core.Types

type subscriber = {
  mutable fd : Unix.file_descr;
  mutable events : string list;
    (* TODO: shouldn't this be a better type than [string]? *)
}

type ipc_conn = {
  socket_path : string;
  server_fd : Unix.file_descr;
  mutable subscribers : subscriber list;
}

type ipc_state =
  | Ipc_inactive
  | Ipc_active of ipc_conn

type action =
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
  | Send_to_output of direction (* keep own tags *)
  | Send_to_output_tags of direction (* take dest tags *)
  (* Focus *)
  | Focus_window of direction
  | Focus_output of direction
  (* Stack manipulation *)
  | Swap_window of direction
  | Zoom
  (* Tags *)
  | Tag_view of int
  | Tag_view_mask of Tag_set.t
  | Tag_toggle_view of int
  | Tag_view_previous
  | Tag_view_cycle of direction
  | Window_tag of int
  | Window_toggle_tag of int
  | Window_tag_mask of Tag_set.t
  (* Layout *)
  | Layout_set of string
  | Layout_cycle of direction
  | Set_mfact of float delta
  | Set_nmaster of int delta
  | Set_gaps_inner of int delta
  | Set_gaps_outer of int delta
  | Set_stack of stack_kind
