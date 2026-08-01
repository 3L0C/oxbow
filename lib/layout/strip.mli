module Item : sig
  type t =
    { consumes : bool
    ; width_fac : float
    }
end

(** [split ~total ~count] is an int list of length [count], where each element
    is equal to [total / count]. If [total mod count <> 0] then
    [total mod count] elements are eqaul to [(total / count) + 1]. *)
val split : total:int -> count:int -> int list

(** [columns ~consumes items] groups [items] into columns. A new column starts
    at each item whose predecessor does not consume. The concatenation of the
    result is [items]. *)
val columns : consumes:('a -> bool) -> 'a list -> 'a list list

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

(** [scroll ~policy ~viewport_w ~max_offset ~offset ~col:(x, w)] is the strip
    offset after applying [policy] to the focused column [col], where [x] is its
    strip-relative position (offset-0 placement minus the usable origin), [w]
    its width. [max_offset] is the strip-relative x of the last column. For
    [Left] and [Visible] the result is clamped to [0, max 0 max_offset], so
    stale offsets self-heal and the tail column can anchor at the left edge. *)
val scroll
  :  policy:Ocdwm_core.Scroll_policy.t
  -> viewport_w:int
  -> max_offset:int
  -> offset:int
  -> col:int * int
  -> int
