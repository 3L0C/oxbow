type 'a t =
  { x : 'a
  ; y : 'a
  ; w : 'a
  ; h : 'a
  }

(** [to_int r] is [r] with each field converted by [Int32.to_int]. *)
val to_int : int32 t -> int t

(** [inset ~by r] shrinks [r] by [by] pixels on every side; width and height
    floor at 1. *)
val inset : by:int -> int t -> int t

(** [contains ~x ~y g] is [true] when the point ([x], [y]) lies inside [g]; the
    right and bottom edges are exclusive. *)
val contains : x:int32 -> y:int32 -> int32 t -> bool
