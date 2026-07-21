module Item : sig
  type t =
    { consumes : bool
    ; width_fac : float
    }
end

(** [layout ~usable ~offset items] is the screen-space geometry of [items]
    arranged as full-height columns on a horizontal strip, in order. Column
    width is the head item's [width_fac] * [usable] width (min 1); windows
    within a column split the height evenly. Strip x [offset] is subtracted, so
    rects may lie outside [usable]. Callers apply [Gaps.post]. *)
val layout
  :  usable:int Ocdwm_core.Rect.t
  -> offset:int
  -> ('a * Item.t) list
  -> ('a * int Ocdwm_core.Rect.t) list
