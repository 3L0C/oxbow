type t =
  | S_static of string
  | S_dynamic of (Symbol_ctx.t -> string)
