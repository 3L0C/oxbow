let move_to_top x xs = x :: List.filter (fun y -> y != x) xs

let spawn cmd =
  match Unix.fork () with
  | 0 -> Unix.execvp "kitty" [||]
  | pid -> ()
