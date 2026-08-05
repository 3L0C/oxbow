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
  section "mfact +0.05" (fun () ->
    cmd env (Layout (Tiling (Mfact { delta = Rel 0.05; scope = Focused }))));
  section "select scheme monocle" (fun () ->
    cmd env (Layout (Tiling (Select { scheme = Monocle; scope = Focused }))));
  section "layout floating" (fun () ->
    cmd env (Layout (Select { layout = Floating; scope = Focused })));
  section "layout scrolling" (fun () ->
    cmd env (Layout (Select { layout = Scrolling; scope = Focused })));
  section "toggle overview" (fun () -> cmd env (Output Toggle_overview));
  section "layouts" (fun () ->
    Harness.ipc env (Query (Layouts { output = None }))
    |> Option.iter (fun j -> print_endline @@ Yojson.Safe.to_string j))
;;
