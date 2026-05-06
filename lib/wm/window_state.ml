type t =
  | W_new
  | W_active
  | W_dirty of { prev : t }
  | W_closing
