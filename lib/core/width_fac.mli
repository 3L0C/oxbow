type t

(** [of_float f] is [f] clamped to [0.1, 1.0]. *)
val of_float : float -> t

(** [to_float t] is the factor as a float. *)
val to_float : t -> float

(** [presets] is the preset factors 1/3, 1/2, and 2/3, in ascending order. *)
val presets : t list

(** [cycle t] is the first preset larger than [t]. Past the last preset, it
    wraps to the first. *)
val cycle : t -> t
