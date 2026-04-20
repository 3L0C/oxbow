(* ocdwm layout types - shared type definitions *)

open Ocdwm_core.Types

type symbol_ctx = {
  focused_index : int;
  count : int;
}

type symbol =
  | S_static of string
  | S_dynamic of (symbol_ctx -> string)

type layout_data = {
  name : string;
  symbol : symbol;
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
    data:layout_params ->
    area:int rect ->
    count:int ->
    int rect list;
}

type external_layout = {
  data : layout_data;
  compute :
    data:layout_params ->
    area:int rect ->
    count:int ->
    int rect list;
  exec : string;
  mutable proc : int option;
}

type layout_entry =
  | L_builtin of builtin_layout
  | L_external of external_layout

type layout_registry = {
  mutable entries : (string * layout_entry) list;
}
