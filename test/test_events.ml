let () =
  let open Oxbow_ipc in
  List.iter
    (fun k ->
       Record.yojson_of_t k
       |> Record.t_of_yojson
       |> Record.yojson_of_t
       |> Yojson.Safe.to_string
       |> Printf.printf "kind: %s\n")
    Record.all;
  List.iter
    (fun k ->
       match Record.of_string (Record.to_string k) with
       | Ok k' -> Printf.printf "kind round trip: %s\n" (Record.to_string k')
       | Error e -> Printf.printf "kind round trip err: %s\n" e)
    Record.all;
  (match Record.of_string "bogus" with
   | Error e -> Printf.printf "bogus kind: %s\n" e
   | Ok k -> Printf.printf "bogus kind accepted: %s\n" (Record.to_string k));
  let subs : Event.Subscribe.t list =
    [ { kinds = []; output = None }; { kinds = [ Tags; Mode ]; output = Some "DP-1" } ]
  in
  List.iter
    (fun (s : Event.Subscribe.t) ->
       Event.Subscribe.yojson_of_t s
       |> Event.Subscribe.t_of_yojson
       |> Event.Subscribe.yojson_of_t
       |> Yojson.Safe.to_string
       |> Printf.printf "subscribe: %s\n")
    subs;
  let events : Event.t list =
    [ Tags
        { output = "DP-1"
        ; viewed = [ 1 ]
        ; occupied = [ 1; 3 ]
        ; urgent = []
        ; focused = [ 1 ]
        }
    ; Window
        { id = 1
        ; identifier = None
        ; title = None
        ; app_id = Some "foot"
        ; output = Some "DP-1"
        ; tags = [ 1; 2 ]
        ; focused = false
        ; urgent = false
        ; captured = false
        ; hidden = true
        ; presentation = "tiled"
        ; sticky = "off"
        ; scratchpad = None
        ; stashed = false
        ; swallowing = false
        ; labels = []
        }
    ; Layout { output = "DP-1"; layout = "tiling"; symbol = "[]="; scheme = Some "even" }
    ; Mode { seat = "default"; mode = "normal" }
    ; Focus
        { seat = "default"
        ; output = Some "DP-1"
        ; title = None
        ; app_id = Some "foot"
        ; tags = Some [ 1; 3 ]
        }
    ; Output { name = Some "DP-1"; labels = []; focused = true; captured = false }
    ]
  in
  List.iter (fun e -> Printf.printf "line: %s\n" (Event.to_line e)) events
;;
