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

(** [scroll ~policy ~viewport_w ~total_w ~offset ~col:(x, w)] is the strip
    offset after applying [policy] to the focused column [col], where [x] its
    strip-relative position (offset-0 placement minus the usable origin), [w]
    its width. The result is clamped to [0, max 0 (total_w - viewport_w)], so
    stale offsets self-heal. *)
val scroll
  :  policy:Ocdwm_core.Scroll_policy.t
  -> viewport_w:int
  -> total_w:int
  -> offset:int
  -> col:int * int
  -> int
