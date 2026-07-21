type 'a t =
  { x : 'a
  ; y : 'a
  ; w : 'a
  ; h : 'a
  }

(** [to_int r] is [r] with each field converted by [Int32.to_int]. *)
val to_int : int32 t -> int t

(** [to_int32 r] is [r] with each field converted by [Int32.of_int]. *)
val to_int32 : int t -> int32 t

(** [inset ~by r] shrinks [r] by [by] pixels on every side; width and height
    floor at 1. *)
val inset : by:int -> int t -> int t

(** [contains ~x ~y g] is [true] when the point ([x], [y]) lies inside [g]; the
    right and bottom edges are exclusive. *)
val contains : x:int32 -> y:int32 -> int32 t -> bool

(** [intersect a b] is the overlapping region of [a] and [b], or [None] when
    they are disjoint; touching edges are disjoint. *)
val intersect : int t -> int t -> int t option
