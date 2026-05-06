open! Ocdwm_core

type t =
  { tags : Tag_set.t option
  ; floating : bool option
  ; output_name : string option
  ; fullscreen : bool option
  }
