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
  section "layout scrolling" (fun () ->
    cmd env (Layout (Select { layout = Scrolling; scope = Focused })));
  section "consume" (fun () -> cmd env (Window (Column_consume Focused)));
  section "focus last in column" (fun () ->
    cmd env (Window (Focus_logical { dir = Next; warp = None; target = Focused })));
  section "zoom last member" (fun () ->
    cmd env (Window (Zoom { warp = None; target = Focused })))
;;
