type 'a t = { mutable body : 'a option }

(** [fill box body] sets [box]'s contents to [body].

    {b Effects:} mutates WM state *)
val fill : 'a t -> 'a -> unit

(** [clear box] empties [box].

    {b Effects:} mutates WM state *)
val clear : 'a t -> unit
