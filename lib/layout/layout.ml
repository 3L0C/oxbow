(* ocdwm layout - layout helpers *)

open Ocdwm_core.Types
open Types

let entry_data = function
  | L_builtin { data; _ }
  | L_external { data; _ } ->
      data

let entry_name = function
  | L_builtin { data; _ }
  | L_external { data; _ } ->
      data.name

let entry_symbol ~(ctx : symbol_ctx) = function
  | L_builtin { data; _ }
  | L_external { data; _ } ->
      begin match data.symbol with
      | S_static s -> s
      | S_dynamic f -> f ctx
      end

let default_layout_entry ~(registry : layout_registry) =
  match List.nth_opt registry.entries 0 with
  | None -> failwith "No layouts registered"
  | Some (_, e) -> e

let default_layout_data ~(registry : layout_registry) =
  match List.nth_opt registry.entries 0 with
  | None -> failwith "No layouts registered"
  | Some (_, e) -> entry_data e

let register
      ~(registry : layout_registry)
      ~(entry : layout_entry)
  =
  let name =
    match entry with
    | L_builtin { data; _ }
    | L_external { data; _ } ->
        data.name
  in
  let dups, rest =
    List.partition (fun (n, _) -> n = name) registry.entries
  in
  if dups <> [] then
    Logs.warn (fun m ->
      m "layout %S already registered, replacing" name);
  registry.entries <- rest @ [ (name, entry) ]

let create_registry () : layout_registry =
  let registry = { entries = [] } in
  let builtins =
    [
      (Tile.name, Tile.symbol, Tile.compute);
      (Monocle.name, Monocle.symbol, Monocle.compute);
      (Floating.name, Floating.symbol, Floating.compute);
    ]
  in
  List.iter
    (fun (name, symbol, compute) ->
       register ~registry
         ~entry:
           (L_builtin { data = { name; symbol }; compute }))
    builtins;
  registry

let find ~(registry : layout_registry) ~(name : string) =
  List.assoc_opt name registry.entries

let cycle
      ~(registry : layout_registry)
      ~(name : string)
      ~(dir : direction)
  =
  let entries =
    if dir = Dir_next then registry.entries
    else List.rev registry.entries
  in
  let rec after = function
    | (n, _) :: [] when n = name -> List.nth_opt entries 0
    | (n, _) :: x :: _ when n = name -> Some x
    | _ :: xs -> after xs
    | [] -> begin
        if entries <> [] then
          Logs.err (fun m ->
            m
              "Unable to find %S in layout registry \
               (removed mid search?)"
               name);
        None
      end
  in
  after entries

let compute ~(entry : layout_entry) =
  match entry with
  | L_builtin { compute; _ }
  | L_external { compute; _ } ->
      compute
