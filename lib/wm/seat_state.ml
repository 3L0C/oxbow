type t =
  | S_new
  | S_active
  | S_dirty of { prev : t }
  | S_closing
