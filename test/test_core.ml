let () =
  let open Ocdwm_core in
  let actions : Action.t list =
    [ Zoom
    ; Spawn "foot"
    ; Focus_window Dir_next
    ; Set_mfact (Delta.Rel 0.05)
    ; Set_mfact (Delta.Abs 0.55)
    ; Tag_view (Tags_concrete (Tag_set.singleton 3))
    ]
  in
  let stacks : Stack_kind.t list = [ Stack_diminish; Stack_dwindle; Stack_even ] in
  let responses : Response.t list =
    [ { ok = true; err = None }; { ok = false; err = Some "Had an error" } ]
  in
  List.iter
    (fun a ->
       let j = Action.yojson_of_t a in
       let a' = Action.t_of_yojson j in
       assert (a = a');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    actions;
  List.iter
    (fun s ->
       let j = Stack_kind.yojson_of_t s in
       let s' = Stack_kind.t_of_yojson j in
       assert (s = s');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    stacks;
  List.iter
    (fun r ->
       let j = Response.yojson_of_t r in
       let r' = Response.t_of_yojson j in
       assert (r = r');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    responses
;;
