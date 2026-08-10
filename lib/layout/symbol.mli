module Ctx : sig
  type t =
    { focused_index : int
    ; count : int
    }
end

(** [render layout ~scheme ~align ~ctx] is the status symbol for [layout].
    [ctx] feeds the monocle index. *)
val render
  :  Oxbow_core.Layout.t
  -> scheme:Oxbow_core.Scheme.t
  -> align:Oxbow_core.Align.t
  -> ctx:Ctx.t
  -> string
