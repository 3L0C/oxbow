open! Ocdwm_core

type t = { mutable entries : (string * Entry.t) list }

let default_layout_entry (registry : t) =
  match List.nth_opt registry.entries 0 with
  | None -> failwith "No layouts registered"
  | Some (_, e) -> e
;;

let default_layout_meta (registry : t) =
  match List.nth_opt registry.entries 0 with
  | None -> failwith "No layouts registered"
  | Some (_, e) -> Entry.meta e
;;

let register (registry : t) entry =
  let name = (Entry.meta entry).name in
  let dups, rest = List.partition (fun (n, _) -> n = name) registry.entries in
  (if not @@ List.is_empty dups
   then Logs.warn @@ fun m -> m "layout %S already registered, replacing" name);
  registry.entries <- rest @ [ name, entry ]
;;

let create () =
  let registry = { entries = [] } in
  let builtins =
    [ Tile.name, Tile.symbol, Tile.compute
    ; Monocle.name, Monocle.symbol, Monocle.compute
    ; Floating.name, Floating.symbol, Floating.compute
    ]
  in
  List.iter
    (fun (name, symbol, compute) ->
       register registry @@ Builtin { meta = { name; symbol }; compute })
    builtins;
  registry
;;

let find (registry : t) name = List.assoc_opt name registry.entries

let cycle (registry : t) name (dir : Direction.Logical.t) =
  let entries = if dir = Next then registry.entries else List.rev registry.entries in
  let rec after = function
    | [ (n, _) ] when n = name -> List.nth_opt entries 0
    | (n, _) :: x :: _ when n = name -> Some x
    | _ :: xs -> after xs
    | [] ->
      (if not @@ List.is_empty entries
       then
         Logs.err
         @@ fun m -> m "Unable to find %S in layout registry (removed mid search?)" name);
      None
  in
  after entries
;;
