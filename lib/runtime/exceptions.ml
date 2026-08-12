exception Unavailable

let unavailable () = raise Unavailable

let guard name f =
  try f () with
  | Unavailable as e -> raise e
  | Eio.Cancel.Cancelled _ as e -> raise e
  | exn ->
    Log.err
    @@ fun m ->
    m "%s raised: %s@.%s" name (Printexc.to_string exn) (Printexc.get_backtrace ())
;;
