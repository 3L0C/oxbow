module Ctx = struct
  type t =
    { focused_index : int
    ; count : int
    }
end

type t =
  | Static of string
  | Dynamic of (Ctx.t -> string)
