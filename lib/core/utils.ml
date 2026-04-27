open Types

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
    | [ x ] when not wrapped -> l x |> aux true
    | x :: xs -> aux wrapped xs
    | [] -> None
  in
  aux false lst

let in_rect ~(x : 'a) ~(y : 'a) ~(g : 'a rect) =
  x >= g.x
  && x < Int32.add g.x g.w
  && y >= g.y
  && y < Int32.add g.y g.h
