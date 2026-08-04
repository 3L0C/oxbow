module Ctx : sig
  type t =
    { focused_index : int
    ; count : int
    }
end

(** [render layout ~scheme ~ctx] is the status symbol for [layout]. For
    [Tiling], the symbol joins the scheme glyph and the stack accent. [ctx]
    feeds the monocle index. [Scrolling] and [Floating] map to one fixed glyph
    each. *)
val render : Oxbow_core.Layout.t -> scheme:Oxbow_core.Scheme.t -> ctx:Ctx.t -> string
