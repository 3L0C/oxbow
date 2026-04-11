(* ocdwm config - window rules and runtime settings *)
open Types

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let default () =
  {
    default_tag_config =
      {
        layout_data = { name = "tile"; symbol = "[]=" };
        layout_params =
          {
            mfact = 0.55;
            nmaster = 1;
            gaps_inner = 0;
            gaps_outer = 0;
            stack = Stack_even;
          };
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
