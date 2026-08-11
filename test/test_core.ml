let () =
  let open Oxbow_core in
  let open Oxbow_ipc in
  let commands : Command.t list =
    [ Window (Zoom { warp = None; target = Focused })
    ; Spawn "foot"
    ; Window (Focus_logical { dir = Next; warp = None; target = Focused })
    ; Layout (Tiling (Mfact { delta = Delta.Rel 0.05; scope = Focused }))
    ; Layout (Tiling (Mfact { delta = Delta.Abs 0.55; scope = Focused }))
    ; Tag (View (Concrete (Tag.Set.singleton 3)))
    ]
  in
  List.iter
    (fun c ->
       Command.yojson_of_t c
       |> Command.t_of_yojson
       |> Command.yojson_of_t
       |> Yojson.Safe.to_string
       |> Printf.printf "command: %s\n")
    commands;
  let responses : Response.t list =
    [ { ok = true; err = None; data = None }
    ; { ok = false; err = Some "Had an error"; data = None }
    ]
  in
  List.iter
    (fun r ->
       Response.yojson_of_t r
       |> Response.t_of_yojson
       |> Response.yojson_of_t
       |> Yojson.Safe.to_string
       |> Printf.printf "response: %s\n")
    responses;
  let colors = [ "#FFFFFF"; "0x01234567"; "0X89AbCdEf"; "bogus" ] in
  List.iter
    (fun c ->
       match Color.of_string c with
       | Ok _ -> Printf.printf "color ok: %s\n" c
       | Error e -> Printf.printf "color err: %s: %s\n" c e)
    colors;
  let all _ = true in
  let hops =
    [ "right, all visible", Ring.hop_right, ( = ) 1, all, [ 1; 2; 3 ]
    ; "right, over hidden", Ring.hop_right, ( = ) 1, ( <> ) 2, [ 1; 2; 3 ]
    ; "right, wrap", Ring.hop_right, ( = ) 3, ( <> ) 2, [ 1; 2; 3 ]
    ; "right, wrap pins hidden prefix", Ring.hop_right, ( = ) 4, ( <> ) 1, [ 1; 2; 3; 4 ]
    ; "left, all visible", Ring.hop_left, ( = ) 1, all, [ 1; 2; 3 ]
    ; "left, over hidden", Ring.hop_left, ( = ) 3, ( <> ) 2, [ 1; 2; 3 ]
    ; "left, wrap", Ring.hop_left, ( = ) 1, ( <> ) 2, [ 1; 2; 3 ]
    ; "no other visible", Ring.hop_right, ( = ) 1, ( = ) 1, [ 1; 2; 3 ]
    ; "sel absent", Ring.hop_right, ( = ) 9, all, [ 1; 2; 3 ]
    ]
  in
  let show l = String.concat ";" @@ List.map string_of_int l in
  List.iter
    (fun (label, fn, sel, vis, l) ->
       Printf.printf "ring hop %s: [%s]\n" label (show (fn sel vis l)))
    hops;
  let arrangements =
    [ "odd", (fun i -> i mod 2 = 1), [ 5; 1; 3 ], [ 1; 2; 3; 4; 5 ]
    ; "even", (fun i -> i mod 2 = 0), [ 4; 2 ], [ 1; 2; 3; 4; 5 ]
    ; "none", (fun _ -> false), [], [ 1; 2; 3; 4; 5 ]
    ; "all", (fun _ -> true), [ 2; 4; 1; 5; 3 ], [ 1; 2; 3; 4; 5 ]
    ; "identity", (fun _ -> true), [ 1; 2; 3; 4; 5 ], [ 1; 2; 3; 4; 5 ]
    ]
  in
  List.iter
    (fun (label, vis, order, l) ->
       Printf.printf "ring rearrange %s: [%s]\n" label (show (Ring.rearrange vis order l)))
    arrangements;
  List.iter
    (fun (label, p) ->
       Width_fac.(of_float p |> cycle |> to_float)
       |> Printf.printf "width fac cycle %s: %.4f\n" label)
    [ "1/3", 1.0 /. 3.0; "1/2", 0.5; "2/3", 2.0 /. 3.0 ]
;;
