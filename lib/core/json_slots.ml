let fields : Yojson.Safe.t -> _ = function
  | `Assoc l -> l
  | _ -> invalid_arg "Json_slots: not a record"
;;

let empty t_of = t_of (`Assoc [])
let is_empty yojson_of v = yojson_of v = `Assoc []

let merge yojson_of t_of ~old ~new_ =
  let news = fields (yojson_of new_) in
  let keep (k, _) = not @@ List.mem_assoc k news in
  t_of (`Assoc (List.filter keep (fields (yojson_of old)) @ news))
;;
