let cmd env (c : Oxbow_ipc.Command.t) = ignore @@ Harness.ipc env (Command c)

let () =
  Harness.run
  @@ fun env fake ~section ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "firefox"));
  section "focus prev" (fun () ->
    cmd env (Window { cmd = Focus_logical { dir = Prev; warp = None }; target = Focused }));
  section "zoom" (fun () ->
    cmd env (Window { cmd = Zoom { warp = None }; target = Focused }));
  section "close emacs" (fun () -> Fake_river.close_window fake ~app_id:(Some "emacs"));
  section "focused" (fun () ->
    Harness.ipc env (Query Focused)
    |> Option.iter (fun j -> print_endline @@ Yojson.Safe.to_string j));
  section "galculator arrives without hint" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "galculator"));
  section "late fixed hint" (fun () ->
    Fake_river.send_dimensions_hint
      fake
      ~app_id:(Some "galculator")
      ~min_w:300l
      ~min_h:200l
      ~max_w:300l
      ~max_h:200l);
  section "galculator floats" (fun () ->
    Harness.oxctl env [ "window"; "list"; "--app-id"; "^galculator$" ])
;;
