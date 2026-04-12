let move_to_top x xs = x :: List.filter (fun y -> y != x) xs

let spawn cmd =
  match Unix.fork () with
  | 0 -> Unix.execvp "kitty" [||]
  | pid -> ()

let rec wrapped_search
          (p : 'a -> bool)
          (l : 'a -> 'a list)
          (lst : 'a list)
  =
  let rec aux (wrapped : bool) = function
    | x :: xs when p x -> Some x
    | x :: [] when not wrapped -> l x |> aux true
    | x :: xs -> aux wrapped xs
    | [] -> None
  in
  aux false lst
