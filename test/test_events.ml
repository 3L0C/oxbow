let check ~expect got =
  if String.equal expect got
  then Printf.printf "ok: %s\n" got
  else (
    Printf.printf "FAIL\n  expect: %s\n  got:    %s\n" expect got;
    exit 1)
;;

let () =
  let open Ocdwm_ipc in
  List.iter
    (fun k ->
       let j = Event.Kind.yojson_of_t k in
       let k' = Event.Kind.t_of_yojson j in
       assert (Event.Kind.equal k k');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    Event.Kind.all;
  List.iter
    (fun k -> assert (Event.Kind.of_string (Event.Kind.to_string k) = Ok k))
    Event.Kind.all;
  (match Event.Kind.of_string "bogus" with
   | Error _ -> print_endline "ok: bogus kind rejected"
   | Ok _ -> assert false);
  let subs : Event.Subscribe.t list =
    [ { kinds = []; output = None }; { kinds = [ Tags; Mode ]; output = Some "DP-1" } ]
  in
  List.iter
    (fun (s : Event.Subscribe.t) ->
       let j = Event.Subscribe.yojson_of_t s in
       let s' = Event.Subscribe.t_of_yojson j in
       assert (s = s');
       Printf.printf "ok: %s\n" (Yojson.Safe.to_string j))
    subs;
  check
    ~expect:{|{"kinds":["tags","mode"],"output":"DP-1"}|}
    (Yojson.Safe.to_string
       (Event.Subscribe.yojson_of_t { kinds = [ Tags; Mode ]; output = Some "DP-1" }));
  check
    ~expect:
      {|{"event":"tags","output":"DP-1","viewed":[1],"occupied":[1,3],"urgent":[],"focused":[1]}|}
    (Event.to_line
       (Tags
          { output = "DP-1"
          ; viewed = [ 1 ]
          ; occupied = [ 1; 3 ]
          ; urgent = []
          ; focused = [ 1 ]
          }));
  check
    ~expect:
      {|{"event":"window","output":"DP-1","focused":false,"title":null,"app_id":"foot","tags":[1,2]}|}
    (Event.to_line
       (Window
          { output = "DP-1"
          ; focused = false
          ; title = None
          ; app_id = Some "foot"
          ; tags = Some [ 1; 2 ]
          }));
  check
    ~expect:{|{"event":"layout","output":"DP-1","layout":"tall","symbol":"[]="}|}
    (Event.to_line (Layout { output = "DP-1"; layout = "tall"; symbol = "[]=" }));
  check
    ~expect:{|{"event":"mode","seat":"default","mode":"normal"}|}
    (Event.to_line (Mode { seat = "default"; mode = "normal" }));
  check
    ~expect:
      {|{"event":"focus","seat":"default","output":"DP-1","title":null,"app_id":"foot","tags":[1,3]}|}
    (Event.to_line
       (Focus
          { seat = "default"
          ; output = Some "DP-1"
          ; title = None
          ; app_id = Some "foot"
          ; tags = Some [ 1; 3 ]
          }))
;;
