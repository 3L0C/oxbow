(* ocdwm layout types - shared type definitions *)

open Ocdwm_core.Types

module Symbol_ctx = struct
  type t =
    { focused_index : int
    ; count : int
    }
end

module Symbol = struct
  type t =
    | S_static of string
    | S_dynamic of (Symbol_ctx.t -> string)
end

module Layout_data = struct
  type t =
    { name : string
    ; symbol : Symbol.t
    }
end

module Layout_params = struct
  type t =
    { mutable mfact : float
    ; mutable nmaster : int
    ; mutable gaps_inner : int
    ; mutable gaps_outer : int
    ; mutable stack : Stack_kind.t
    }
end

module Compute = struct
  type t = data:Layout_params.t -> area:int Rect.t -> count:int -> int Rect.t list
end

module Builtin_layout = struct
  type t =
    { data : Layout_data.t
    ; compute : Compute.t
    }
end

module External_layout = struct
  type t =
    { data : Layout_data.t
    ; compute : Compute.t
    ; exec : string
    ; mutable proc : int option
    }
end

module Layout_entry = struct
  type t =
    | L_builtin of Builtin_layout.t
    | L_external of External_layout.t
end

module Layout_registry = struct
  type t = { mutable entries : (string * Layout_entry.t) list }
end
