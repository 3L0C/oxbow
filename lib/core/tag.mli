module Set : sig
  type t

  (** [max_tag] is the largest valid tag index. *)
  val max_tag : int

  (** [min_tag] is the smallest valid tag index. *)
  val min_tag : int

  (** [empty] is the empty tag set. *)
  val empty : t

  (** [all] is the set containing all tags from [min_tag] to [max_tag]. *)
  val all : t

  (** [in_range i] is true if [i] is between [min_tag..max_tag]. *)
  val in_range : int -> bool

  (** [singleton i] is the set containing only tag [i].
    Raises [Invalid_argument] if [i] is outside [min_tag..max_tag]. *)
  val singleton : int -> t

  (** [of_indices lst] is the set of tags whose indices appear in [lst].
      Raises [Invalid_argument] if any element of [lst] is outside
      [min_tag..max_tag]. *)
  val of_indices : int list -> t

  (** [is_empty s] is [true] when [s] contains no tags. *)
  val is_empty : t -> bool

  (** [mem i s] is [true] when tag [i] is in [s].
      Returns [false] when [i] is outside [min_tag..max_tag]. *)
  val mem : int -> t -> bool

  (** [equal a b] is [true] when [a] and [b] contain the same tags. *)
  val equal : t -> t -> bool

  (** [intersects a b] is [true] when [a] and [b] share at least one tag. *)
  val intersects : t -> t -> bool

  (** [subset a b] is [true] when every tag in [a] is also in [b]. *)
  val subset : t -> t -> bool

  (** [union a b] is the set of tags in either [a] or [b]. *)
  val union : t -> t -> t

  (** [inter a b] is the set of tags in both [a] and [b]. *)
  val inter : t -> t -> t

  (** [diff a b] is the set of tags in [a] but not in [b]. *)
  val diff : t -> t -> t

  (** [symmetric_diff a b] is the set of tags in exactly one of [a] or [b]. *)
  val symmetric_diff : t -> t -> t

  (** [first s] is the smallest tag in [s], or [None] if [s] is empty. *)
  val first : t -> t option

  (** [first_index s] is the smallest tag index in [s], or [None] if [s] is empty. *)
  val first_index : t -> int option

  (** [last s] is the largest tag in [s], or [None] if [s] is empty. *)
  val last : t -> t option

  (** [last_index s] is the largest tag index in [s], or [None] if [s] is empty. *)
  val last_index : t -> int option

  (** [cardinality s] is the number of tags in [s]. *)
  val cardinality : t -> int

  (** [fold f s init] is [f i_n (... (f i_1 init))] where [i_1..i_n] are
      the tag indices in [s] in ascending order. *)
  val fold : (int -> 'a -> 'a) -> t -> 'a -> 'a

  (** [iter f s] applies [f] to each tag in [s] in ascending order. *)
  val iter : (t -> unit) -> t -> unit

  (** [iteri f s] same as {iter}, but [f] is applied to the index of the set as
      first argument, and the element itself as the second argument. *)
  val iteri : (int -> t -> unit) -> t -> unit

  (** [to_list s] is the tag set [s] as a singleton set list in ascending order. *)
  val to_list : t -> t list

  (** [to_index_list s] is the tag indices in [s] in ascending order. *)
  val to_index_list : t -> int list

  (** [next s] is [s] with its lowest set tag advanced by one position,
      wrapping from [max_tag] to [min_tag], or [empty] if [s] is empty. *)
  val next : t -> t

  (** [prev s] is [s] with its lowest set tag moved back by one position,
      wrapping from [min_tag] to [max_tag], or [empty] if [s] is empty. *)
  val prev : t -> t

  (** [next_occupied ~selected ~occupied] is the next tag in [occupied]
      after the lowest set tag in [selected], wrapping at [max_tag]. If
      [occupied] is empty, returns [selected] unchanged. If [selected] is
      empty, returns the lowest tag in [occupied]. *)
  val next_occupied : selected:t -> occupied:t -> t

  (** [prev_occupied ~selected ~occupied] is the previous tag in [occupied]
      before the lowest set tag in [selected], wrapping at [min_tag]. If
      [occupied] is empty, returns [selected] unchanged. If [selected] is
      empty, returns the highest tag in [occupied]. *)
  val prev_occupied : selected:t -> occupied:t -> t

  (** [to_int s] is the underlying bitmask of [s] as a plain [int]. *)
  val to_int : t -> int

  (** [of_int n] is the set whose bits are those of [n], masked to
      [min_tag..max_tag]. Bits outside that range are silently dropped. *)
  val of_int : int -> t

  (** [of_string s] is the set of tags represented by [s]. This may be in the form
      of [0xff], [0b01], [0o17], [1,2,5], or [1-3,5]. Is [Error msg] if malformed. *)
  val of_string : string -> (t, string) result

  (** [to_string s] is the string representing [s]. *)
  val to_string : t -> string

  val yojson_of_t : t -> Yojson.Safe.t
  val t_of_yojson : Yojson.Safe.t -> t
end

module Arg : sig
  type t =
    | Concrete of Set.t
    | Occupied

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Policy : sig
  type t =
    | Keep
    | Take

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end
