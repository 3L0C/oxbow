module Meta = struct
  type t =
    { name : string
    ; symbol : Symbol.t
    }
end

type t =
  | Builtin of
      { meta : Meta.t
      ; compute : Compute.t
      }
  | External of
      { meta : Meta.t
      ; compute : Compute.t
      ; exec : string
      ; mutable pid : int option
      }

let meta = function
  | Builtin { meta; _ } | External { meta; _ } -> meta
;;

let name e = (meta e).name

let symbol ctx e =
  match (meta e).symbol with
  | Symbol.Static s -> s
  | Symbol.Dynamic f -> f ctx
;;

let compute = function
  | Builtin { compute; _ } | External { compute; _ } -> compute
;;
