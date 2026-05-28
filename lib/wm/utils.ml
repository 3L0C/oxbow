open! Ocdwm_core
open! Types

let move_to_top x xs = x :: List.filter (fun y -> y != x) xs

let spawn cmd =
  let command = [| "/bin/sh"; "-c"; cmd |] in
  match Unix.fork () with
  | 0 ->
    (try Unix.setsid () |> ignore with
     | Unix.Unix_error _ ->
       Printf.eprintf "Utils.spawn: setsid failed while trying to spawn %S\n" cmd);
    (try Unix.execv command.(0) command with
     | _ -> Printf.eprintf "Utils.spawn: failed to spawn %S\n" cmd);
    Exit.unavailable ()
  | _ -> ()
;;

let rec wrapped_search (p : 'a -> bool) (l : 'a -> 'a list) (lst : 'a list) =
  let rec aux (wrapped : bool) = function
    | x :: xs when p x -> Some x
    | [ x ] when not wrapped -> l x |> aux true
    | x :: xs -> aux wrapped xs
    | [] -> None
  in
  aux false lst
;;

let in_rect ~(x : 'a) ~(y : 'a) ~(g : 'a Rect.t) =
  x >= g.x && x < Int32.add g.x g.w && y >= g.y && y < Int32.add g.y g.h
;;

let opts_are_equal (a : 'a option) (b : 'a option) = Option.equal ( == ) a b

let opt_holds (o : 'a option) (v : 'a) =
  match o with
  | Some x -> x == v
  | None -> false
;;

let next_or_first (e : 'a) = function
  | [] -> None
  | first :: _ as lst ->
    let rec aux = function
      | x :: y :: xs when x == e -> Some y
      | [ x ] when x == e -> Some first
      | _ :: rest -> aux rest
      | [] -> None
    in
    aux lst
;;

let prev_or_last (e : 'a) (lst : 'a list) = List.rev lst |> next_or_first e

let shift_right p l =
  let rec aux acc = function
    | [ x ] when p x -> x :: List.rev acc
    | x :: y :: xs when p x -> (List.rev @@ (x :: y :: acc)) @ xs
    | x :: xs -> aux (x :: acc) xs
    | [] -> List.rev acc
  in
  aux [] l
;;

let shift_left p l = List.rev @@ shift_right p @@ List.rev l
