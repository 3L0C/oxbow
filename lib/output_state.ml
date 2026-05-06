type t =
  | O_active
  | O_dirty of { prev : t }
  | O_removed
