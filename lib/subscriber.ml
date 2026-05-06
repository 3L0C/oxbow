type t =
  { mutable fd : Unix.file_descr
  ; mutable events : string list
    (* TODO: shouldn't this be a better type than [string]? *)
  }
