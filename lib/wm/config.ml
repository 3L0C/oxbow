module Rwm = Ocdwm_protocol.River_window_management_v1_client

type t =
  { default_tag_config : Tag_data.t
  ; borders : Border_config.t
  ; mutable modkey : Rwm.River_seat_v1.Modifiers.t
  ; mutable rules : Window_rule.t list
  ; mutable focus_follows_pointer : bool
  }

let default_layout_params =
  Layout_params.
    { mfact = 0.55; nmaster = 1; gaps_inner = 10; gaps_outer = 20; stack = Stack_even }
;;

let default_borders =
  Border_config.
    { width = 4
    ; focused_color = 0xFFFFFFl
    ; unfocused_color = 0xFFFFFFl
    ; urgent_color = 0xFFFFFFl
    }
;;

let create_tag_data ~(entry : Layout_entry.t) : Tag_data.t =
  { layout_params = default_layout_params; layout_entry = entry }
;;

let default (entry : Layout_entry.t) : t =
  { default_tag_config = { layout_params = default_layout_params; layout_entry = entry }
  ; borders = default_borders
  ; modkey = Rwm.River_seat_v1.Modifiers.(Int32.(logor mod4 ctrl))
  ; rules = []
  ; focus_follows_pointer = true
  }
;;
