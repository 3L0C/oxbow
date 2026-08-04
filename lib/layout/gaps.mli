(** [pre gaps area] is [area] inset by [gaps]' outer gaps minus half its inner
    gaps, clamped to a non-negative inset. Layouts compute gapless; gaps are
    applied only by the arrange pipeline. *)
val pre : Params.Gaps.t -> int Oxbow_core.Rect.t -> int Oxbow_core.Rect.t

(** [post gaps rect] is [rect] inset by half of [gaps]' inner gaps. *)
val post : Params.Gaps.t -> int Oxbow_core.Rect.t -> int Oxbow_core.Rect.t
