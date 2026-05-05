(* ocdwm config types - shared type definitions *)

module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_core.Types
open Ocdwm_layout.Types

module Tag_data = struct
  type t =
    { layout_params : Layout_params.t
    ; mutable layout_entry : Layout_entry.t
    }
end

module Rule_pattern = struct
  type t =
    { app_id : string option
    ; title : string option
    }
end

module Rule_apply = struct
  type t =
    { tags : Tag_set.t option
    ; floating : bool option
    ; output_name : string option
    ; fullscreen : bool option
    }
end

module Window_rule = struct
  type t =
    { pattern : Rule_pattern.t
    ; apply : Rule_apply.t
    }
end

module Border_config = struct
  type t =
    { mutable width : int
    ; mutable focused_color : int32
    ; mutable unfocused_color : int32
    ; mutable urgent_color : int32
    }
end

module Config_t = struct
  type t =
    { default_tag_config : Tag_data.t
    ; borders : Border_config.t
    ; mutable modkey : Rwm.River_seat_v1.Modifiers.t
    ; mutable rules : Window_rule.t list
    ; mutable focus_follows_pointer : bool
    }
end
