type t

(** [of_float f] is [f] clamped to [0.1, 1.0]. *)
val of_float : float -> t

(** [to_float t] is the factor as a float. *)
val to_float : t -> float
