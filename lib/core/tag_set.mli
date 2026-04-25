(* ocdwm tag_set - tag set interface *)

type t

val max_tag : int
(** [max_tag] is the largest valid tag index. *)

val min_tag : int
(** [min_tag] is the smallest valid tag index. *)

val empty : t
(** [empty] is the empty tag set. *)

val all : t
(** [all] is the set containing all tags from [min_tag] to [max_tag]. *)

val in_range : int -> bool
(** [in_range i] is true if [i] is between [min_tag..max_tag]. *)

val singleton : int -> t
(** [singleton i] is the set containing only tag [i].
    Raises [Invalid_argument] if [i] is outside [min_tag..max_tag]. *)

val of_indices : int list -> t
(** [of_indices lst] is the set of tags whose indices appear in [lst].
    Raises [Invalid_argument] if any element of [lst] is outside
    [min_tag..max_tag]. *)

val is_empty : t -> bool
(** [is_empty s] is [true] when [s] contains no tags. *)

val mem : int -> t -> bool
(** [mem i s] is [true] when tag [i] is in [s].
    Raises [Invalid_argument] if [i] is outside [min_tag..max_tag]. *)

val equal : t -> t -> bool
(** [equal a b] is [true] when [a] and [b] contain the same tags. *)

val intersects : t -> t -> bool
(** [intersects a b] is [true] when [a] and [b] share at least one tag. *)

val subset : t -> t -> bool
(** [subset a b] is [true] when every tag in [a] is also in [b]. *)

val union : t -> t -> t
(** [union a b] is the set of tags in either [a] or [b]. *)

val inter : t -> t -> t
(** [inter a b] is the set of tags in both [a] and [b]. *)

val diff : t -> t -> t
(** [diff a b] is the set of tags in [a] but not in [b]. *)

val symmetric_diff : t -> t -> t
(** [symmetric_diff a b] is the set of tags in exactly one of [a] or [b]. *)

val first : t -> int option
(** [first s] is the smallest tag index in [s], or [None] if [s] is empty. *)

val last : t -> int option
(** [last s] is the largest tag index in [s], or [None] if [s] is empty. *)

val cardinality : t -> int
(** [cardinality s] is the number of tags in [s]. *)

val fold : (int -> 'a -> 'a) -> t -> 'a -> 'a
(** [fold f s init] is [f i_n (... (f i_1 init))] where [i_1..i_n] are
    the tag indices in [s] in ascending order. *)

val iter : (int -> unit) -> t -> unit
(** [iter f s] applies [f] to each tag index in [s] in ascending order. *)

val to_list : t -> int list
(** [to_list s] is the tag indices in [s] in ascending order. *)

val next : t -> t
(** [next s] is [s] with its lowest set tag advanced by one position,
    wrapping from [max_tag] to [min_tag], or [empty] if [s] is empty. *)

val prev : t -> t
(** [prev s] is [s] with its lowest set tag moved back by one position,
    wrapping from [min_tag] to [max_tag], or [empty] if [s] is empty. *)

val next_occupied : selected:t -> occupied:t -> t
(** [next_occupied ~selected ~occupied] is the next tag in [occupied]
    after the lowest set tag in [selected], wrapping at [max_tag]. If
    [occupied] is empty, returns [selected] unchanged. If [selected] is
    empty, returns the lowest tag in [occupied]. *)

val prev_occupied : selected:t -> occupied:t -> t
(** [prev_occupied ~selected ~occupied] is the previous tag in [occupied]
    before the lowest set tag in [selected], wrapping at [min_tag]. If
    [occupied] is empty, returns [selected] unchanged. If [selected] is
    empty, returns the highest tag in [occupied]. *)

val to_int : t -> int
(** [to_int s] is the underlying bitmask of [s] as a plain [int]. *)

val of_int : int -> t
(** [of_int n] is the set whose bits are those of [n], masked to
    [min_tag..max_tag]. Bits outside that range are silently dropped. *)
