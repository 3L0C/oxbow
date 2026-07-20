(** [pre params area] is [area] inset by [params]' outer gaps minus half its
    inner gaps, clamped to a non-negative inset. Layouts compute gapless; gaps
    are applied only by the arrange pipeline. *)
val pre : Params.t -> int Ocdwm_core.Rect.t -> int Ocdwm_core.Rect.t

(** [post params rect] is [rect] inset by half of [params]' inner gaps. *)
val post : Params.t -> int Ocdwm_core.Rect.t -> int Ocdwm_core.Rect.t
