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
       let j = Command.yojson_of_t c in
       let c' = Command.t_of_yojson j in
       assert (c = c');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    commands;
  let responses : Response.t list =
    [ { ok = true; err = None; data = None }
    ; { ok = false; err = Some "Had an error"; data = None }
    ]
  in
  List.iter
    (fun r ->
       let j = Response.yojson_of_t r in
       let r' = Response.t_of_yojson j in
       assert (r = r');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    responses;
  let colors = [ "#FFFFFF"; "0x01234567"; "0X89AbCdEf" ] in
  List.iter
    (fun c ->
       match Color.of_string c with
       | Ok _ -> Printf.printf "ok: %s\n" c
       | Error _ ->
         Printf.eprintf "failed: %s\n" c;
         assert false)
    colors;
  let all _ = true in
  let hops =
    [ "right, all visible", Ring.hop_right, ( = ) 1, all, [ 1; 2; 3 ], [ 2; 1; 3 ]
    ; "right, over hidden", Ring.hop_right, ( = ) 1, ( <> ) 2, [ 1; 2; 3 ], [ 2; 3; 1 ]
    ; "right, wrap", Ring.hop_right, ( = ) 3, ( <> ) 2, [ 1; 2; 3 ], [ 3; 1; 2 ]
    ; ( "right, wrap pins hidden prefix"
      , Ring.hop_right
      , ( = ) 4
      , ( <> ) 1
      , [ 1; 2; 3; 4 ]
      , [ 1; 4; 2; 3 ] )
    ; "left, all visible", Ring.hop_left, ( = ) 1, all, [ 1; 2; 3 ], [ 2; 3; 1 ]
    ; "left, over hidden", Ring.hop_left, ( = ) 3, ( <> ) 2, [ 1; 2; 3 ], [ 3; 1; 2 ]
    ; "left, wrap", Ring.hop_left, ( = ) 1, ( <> ) 2, [ 1; 2; 3 ], [ 2; 3; 1 ]
    ; "no other visible", Ring.hop_right, ( = ) 1, ( = ) 1, [ 1; 2; 3 ], [ 1; 2; 3 ]
    ; "sel absent", Ring.hop_right, ( = ) 9, all, [ 1; 2; 3 ], [ 1; 2; 3 ]
    ]
  in
  List.iter
    (fun (label, fn, sel, vis, l, expected) ->
       let r = fn sel vis l in
       if r = expected
       then Printf.printf "ok: ring hop %s\n" label
       else (
         Printf.eprintf
           "failed: ring hop %s: [%s]\n"
           label
           (String.concat ";" @@ List.map string_of_int r);
         assert false))
    hops;
  let arrangements =
    [ "odd", (fun i -> i mod 2 = 1), [ 5; 1; 3 ], [ 1; 2; 3; 4; 5 ], [ 5; 2; 1; 4; 3 ]
    ; "even", (fun i -> i mod 2 = 0), [ 4; 2 ], [ 1; 2; 3; 4; 5 ], [ 1; 4; 3; 2; 5 ]
    ; "none", (fun _ -> false), [], [ 1; 2; 3; 4; 5 ], [ 1; 2; 3; 4; 5 ]
    ; "all", (fun _ -> true), [ 2; 4; 1; 5; 3 ], [ 1; 2; 3; 4; 5 ], [ 2; 4; 1; 5; 3 ]
    ; "identity", (fun _ -> true), [ 1; 2; 3; 4; 5 ], [ 1; 2; 3; 4; 5 ], [ 1; 2; 3; 4; 5 ]
    ]
  in
  List.iter
    (fun (label, vis, order, l, expected) ->
       let r = Ring.rearrange vis order l in
       if r = expected
       then Printf.printf "ok: ring rearrange %s\n" label
       else (
         Printf.eprintf
           "failed: ring rearrange %s: [%s]\n"
           label
           (String.concat ";" @@ List.map string_of_int r);
         assert false))
    arrangements;
  let width_facs =
    [ "1/3", 1.0 /. 3.0, 0.5; "1/2", 0.5, 2.0 /. 3.0; "2/3", 2.0 /. 3.0, 1.0 /. 3.0 ]
  in
  List.iter
    (fun (label, p, expected) ->
       let wf = Width_fac.of_float p in
       let r = Width_fac.(cycle wf |> to_float) in
       if Float.compare r expected = 0
       then Printf.printf "ok: width fac cycle %s\n" label
       else (
         Printf.eprintf "failed: width fac cycle %s\n" label;
         assert false))
    width_facs
;;
