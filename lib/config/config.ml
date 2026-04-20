(* ocdwm config - window rules and runtime settings *)
open Ocdwm_layout.Types
open Types
module Layout = Ocdwm_layout.Layout

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let create_tag_data ~(entry : layout_entry) =
  {
    layout_params =
      {
        mfact = 0.55;
        nmaster = 1;
        gaps_inner = 0;
        gaps_outer = 0;
        stack = Stack_even;
      };
    layout_entry = entry;
  }

let default (entry : layout_entry) =
  {
    default_tag_config =
      {
        layout_params =
          {
            mfact = 0.55;
            nmaster = 1;
            gaps_inner = 0;
            gaps_outer = 0;
            stack = Stack_even;
          };
        layout_entry = entry;
      };
    borders =
      {
        width = 4;
        focused_color = 0xFFFFFFl;
        unfocused_color = 0xFFFFFFl;
        urgent_color = 0xFFFFFFl;
      };
    modkey = Rwm.River_seat_v1.Modifiers.mod4;
    rules = [];
  }
