(* ocdwm config - window rules and runtime settings *)
module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Layout = Ocdwm_layout.Layout
module Tag_data = Types.Tag_data
open Ocdwm_layout.Types

type t = Types.Config_t.t

let create_tag_data ~(entry : Layout_entry.t) : Tag_data.t =
  { layout_params =
      { mfact = 0.55; nmaster = 1; gaps_inner = 0; gaps_outer = 0; stack = Stack_even }
  ; layout_entry = entry
  }
;;

let default (entry : Layout_entry.t) : t =
  { default_tag_config =
      { layout_params =
          { mfact = 0.55
          ; nmaster = 1
          ; gaps_inner = 0
          ; gaps_outer = 0
          ; stack = Stack_even
          }
      ; layout_entry = entry
      }
  ; borders =
      { width = 4
      ; focused_color = 0xFFFFFFl
      ; unfocused_color = 0xFFFFFFl
      ; urgent_color = 0xFFFFFFl
      }
  ; modkey = Rwm.River_seat_v1.Modifiers.mod4
  ; rules = []
  ; focus_follows_pointer = true
  }
;;
