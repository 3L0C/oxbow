let () =
  let open Ocdwm_core in
  let open Ocdwm_ipc in
  let commands : Command.t list =
    [ Window Zoom
    ; Execute (Spawn "foot")
    ; Window (Focus_logical Next)
    ; Set (Mfact (Delta.Rel 0.05))
    ; Set (Mfact (Delta.Abs 0.55))
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
  let stacks : Stack_kind.t list = [ Even; Diminish; Dwindle ] in
  List.iter
    (fun s ->
       let j = Stack_kind.yojson_of_t s in
       let s' = Stack_kind.t_of_yojson j in
       assert (s = s');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    stacks;
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
    colors
;;
