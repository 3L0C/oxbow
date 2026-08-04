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
    cmd env (Window (Focus_logical { dir = Prev; warp = None })));
  section "zoom" (fun () -> cmd env (Window (Zoom { warp = None })));
  section "close emacs" (fun () -> Fake_river.close_window fake ~app_id:(Some "emacs"));
  section "focused" (fun () ->
    Harness.ipc env (Query Focused)
    |> Option.iter (fun j -> print_endline @@ Yojson.Safe.to_string j))
;;
