(** [move_to_top x xs] is [xs] with [x] at the head and every prior occurrence
    (by [==]) removed. *)
val move_to_top : 'a -> 'a list -> 'a list

(** [wrapped_search p l lst] is the first element of [lst] satisfying [p]; when
    [lst] is exhausted, the search continues once through [l] (the caller's
    wrap-around list).  [None] when both passes fail. *)
val wrapped_search : ('a -> bool) -> ('a -> 'a list) -> 'a list -> 'a option

(** [next_or_first e lst] is the element after [e] (by [==]), wrapping from the
    tail to the head; [None] when [e] is not in [lst]. *)
val next_or_first : 'a -> 'a list -> 'a option

(** [prev_or_last e lst] is the element before [e] (by [==]), wrapping from the
    head to the tail; [None] when [e] is not in [lst]. *)
val prev_or_last : 'a -> 'a list -> 'a option

(** [shift_right p l] swaps the first element satisfying [p] with its successor;
    the last element wraps to the head. [l] unchanged when nothing satisfies
    [p]. *)
val shift_right : ('a -> bool) -> 'a list -> 'a list

(** [shift_left p l] swaps the first element satisfying [p] with its predecessor;
    the head element wraps to the tail. [l] unchanged when nothing satisfies
    [p]. *)
val shift_left : ('a -> bool) -> 'a list -> 'a list
