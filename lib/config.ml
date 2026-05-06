module Rwm = Ocdwm_protocol.River_window_management_v1_client

type t =
  { default_tag_config : Tag_data.t
  ; borders : Border_config.t
  ; mutable modkey : Rwm.River_seat_v1.Modifiers.t
  ; mutable rules : Window_rule.t list
  ; mutable focus_follows_pointer : bool
  }

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
