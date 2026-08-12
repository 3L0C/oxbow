type t = string

let normal = "normal"
let locked = "locked"
let equal = String.equal
let to_string = Fun.id

let resolve name ~declared =
  Option.to_result ~none:(Printf.sprintf "mode not declared: %S" name)
  @@ List.find_opt (equal name) declared
;;

let declare name ~declared =
  if List.mem name declared
  then Error (Printf.sprintf "mode already declared: %S" name)
  else Ok name
;;
