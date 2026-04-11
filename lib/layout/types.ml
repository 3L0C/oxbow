(* ocdwm layout types - shared type definitions *)

open Ocdwm_core.Types

type layout_data = {
  name : string;
  mutable symbol : string;
}

type layout_params = {
  mutable mfact : float;
  mutable nmaster : int;
  mutable gaps_inner : int;
  mutable gaps_outer : int;
  mutable stack : stack_kind;
}

type builtin_layout = {
  data : layout_data;
  compute :
    area:int rect ->
    count:int ->
    params:layout_params ->
    int rect list;
}

type external_layout = {
  layout_data : layout_data;
  exec : string;
  mutable proc : int option;
}

type layout_entry =
  | Builtin of builtin_layout
  | External of external_layout

module LayoutMap = Map.Make (String)

type layout_registry = {
  mutable entries : layout_entry LayoutMap.t;
}
