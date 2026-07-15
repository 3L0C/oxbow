module Meta : sig
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

(** [meta e] is [e]'s metadata. *)
val meta : t -> Meta.t

(** [name e] is [e]'s registered name. *)
val name : t -> string

(** [symbol ctx e] renders [e]'s status-line symbol against [ctx]. *)
val symbol : Symbol.Ctx.t -> t -> string

(** [compute e] is [e]'s layout function. *)
val compute : t -> Compute.t
