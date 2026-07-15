let opt_equal a b = Option.equal ( == ) a b

let opt_holds o v =
  match o with
  | Some x -> x == v
  | None -> false
;;
