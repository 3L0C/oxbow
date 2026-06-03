module Rwm = Ocdwm_protocol.River_window_management_v1_client

type t =
  { default_tag_config : Tag_data.t
  ; borders : Border_config.t
  ; mutable modkey : Rwm.River_seat_v1.Modifiers.t
  ; mutable rules : Window_rule.t list
  ; mutable focus_follows_pointer : bool
  ; mutable repeat_rate : int
  ; mutable repeat_delay : int
  }

(** [create_tag_data entry] is the [Tag_data.t] created from [entry]. *)
val create_tag_data : entry:Layout_entry.t -> Tag_data.t

(** [default entry] is the default config given [entry]. *)
val default : Layout_entry.t -> t
