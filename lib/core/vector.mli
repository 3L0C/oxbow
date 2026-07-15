type t =
  { x : int
  ; y : int
  }

(** [center r] is the geometric center of [r]. Port of river-classic's
    [Vector.positionOfBox]. *)
val center : int Rect.t -> t

(** [diff a b] is [b - a]. *)
val diff : t -> t -> t

(** [direction v] classifies [v] into one of four quadrants by dominant axis:
    [|dy| > |dx|] is up/down, else left/right. Is [None] for the zero vector. *)
val direction : t -> Direction.Spatial.t option

(** [length_squared v] is [x*x + y*y]. *)
val length_squared : t -> int

(** [nearest_in_direction ~from ~dir project xs] is the element of [xs] closest
    to [from] in direction [dir], or [None] if none qualifies. [project x]
    returns [Some] then candidate's center, or [None] to exclude [x] from the
    search. *)
val nearest_in_direction
  :  from:t
  -> dir:Direction.Spatial.t
  -> ('a -> t option)
  -> 'a list
  -> 'a option
