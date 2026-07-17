type t

(** [of_string s] parses [s] as a hexadecimal color: six digits ([RRGGBB], alpha
    implied [FF]) or eight ([RRGGBBAA]), with an optional [#] or [0x] prefix. *)
val of_string : string -> (t, string) result

(** [of_string_exn s] is [of_string s].

    @raise Invalid_argument on parse failure. *)
val of_string_exn : string -> t

(** [to_string c] is the canonical form [#rrggbbaa]. *)
val to_string : t -> string

(** [channels color] splits 8-bit RGBA [color] into four 32-bit channel values
    (r, g, b, a), each byte replicated across its 32 bits. *)
val channels : t -> int32 * int32 * int32 * int32

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
