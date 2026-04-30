open Types

let move_to_top x xs = x :: List.filter (fun y -> y != x) xs

let spawn cmd =
  let command = [| "/bin/sh"; "-c"; cmd |] in
  match Unix.fork () with
  | 0 -> begin
      begin try Unix.setsid () |> ignore with
      | Unix.Unix_error _ ->
          Printf.eprintf
            "Utils.spawn: setsid failed while trying to \
             spawn %S\n"
             cmd
      end;
      begin try Unix.execv command.(0) command with
      | _ ->
          Printf.eprintf "Utils.spawn: failed to spawn %S\n"
            cmd
      end;
      Exit.unavailable ()
    end
  | _ -> ()

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

let opts_are_equal (a : 'a option) (b : 'a option) =
  match (a, b) with
  | None, None -> true
  | Some x, Some y -> x == y
  | _ -> false

let opt_holds (o : 'a option) (v : 'a) =
  match o with
  | Some x -> x == v
  | None -> false
