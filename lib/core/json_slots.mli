(** [empty t_of] is the record with every slot absent. *)
val empty : (Yojson.Safe.t -> 'a) -> 'a

(** [is_empty yojson_of v] is true when every slot of [v] is absent. *)
val is_empty : ('a -> Yojson.Safe.t) -> 'a -> bool

(** [merge yojson_of t_of ~old ~new_] keeps each slot of [old] where [new_]
    holds no value. *)
val merge : ('a -> Yojson.Safe.t) -> (Yojson.Safe.t -> 'a) -> old:'a -> new_:'a -> 'a
