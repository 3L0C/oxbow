open! Ocdwm_core

let entry_data = function
  | Layout_entry.L_builtin { data; _ } | Layout_entry.L_external { data; _ } -> data
;;

let entry_name = function
  | Layout_entry.L_builtin { data; _ } | Layout_entry.L_external { data; _ } -> data.name
;;

let entry_symbol ~(ctx : Symbol_ctx.t) = function
  | Layout_entry.L_builtin { data; _ } | Layout_entry.L_external { data; _ } ->
    (match data.symbol with
     | S_static s -> s
     | S_dynamic f -> f ctx)
;;

let default_layout_entry ~(registry : Layout_registry.t) =
  match List.nth_opt registry.entries 0 with
  | None -> failwith "No layouts registered"
  | Some (_, e) -> e
;;

let default_layout_data ~(registry : Layout_registry.t) =
  match List.nth_opt registry.entries 0 with
  | None -> failwith "No layouts registered"
  | Some (_, e) -> entry_data e
;;

let register ~(registry : Layout_registry.t) ~(entry : Layout_entry.t) =
  let name =
    match entry with
    | L_builtin { data; _ } | L_external { data; _ } -> data.name
  in
  let dups, rest = List.partition (fun (n, _) -> n = name) registry.entries in
  (if dups <> []
   then Logs.warn @@ fun m -> m "layout %S already registered, replacing" name);
  registry.entries <- rest @ [ name, entry ]
;;

let create_registry () =
  let registry : Layout_registry.t = { entries = [] } in
  let builtins =
    [ Tile.name, Tile.symbol, Tile.compute
    ; Monocle.name, Monocle.symbol, Monocle.compute
    ; Floating.name, Floating.symbol, Floating.compute
    ]
  in
  List.iter
    (fun (name, symbol, compute) ->
       register ~registry ~entry:(L_builtin { data = { name; symbol }; compute }))
    builtins;
  registry
;;

let find ~(registry : Layout_registry.t) ~(name : string) =
  List.assoc_opt name registry.entries
;;

let cycle ~(registry : Layout_registry.t) ~(name : string) ~(dir : Logical_direction.t) =
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

let compute ~(entry : Layout_entry.t) =
  match entry with
  | L_builtin { compute; _ } | L_external { compute; _ } -> compute
;;
