(* ocdwm config types - shared type definitions *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_core.Types
open Ocdwm_layout.Types

type tag_data = {
  layout_params : layout_params;
  mutable layout_entry : layout_entry;
}

type rule_pattern = {
  app_id : string option;
  title : string option;
}

type rule_apply = {
  tags : Tag_set.t option;
  floating : bool option;
  output_name : string option;
  fullscreen : bool option;
}

type window_rule = {
  pattern : rule_pattern;
  apply : rule_apply;
}

type border_config = {
  mutable width : int;
  mutable focused_color : int32;
  mutable unfocused_color : int32;
  mutable urgent_color : int32;
}

type config = {
  default_tag_config : tag_data;
  borders : border_config;
  mutable modkey : Rwm.River_seat_v1.Modifiers.t;
  mutable rules : window_rule list;
  mutable focus_follows_pointer : bool;
}
