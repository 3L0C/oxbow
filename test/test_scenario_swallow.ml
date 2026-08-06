let cmd env (c : Oxbow_ipc.Command.t) = ignore @@ Harness.ipc env (Command c)

let () =
  (* fake process tree: mpv 100 -> foot 42 -> shell 7 -> init 1 *)
  let table = [ 100, 42; 42, 7; 7, 1 ] in
  (Oxbow_ops.Swallow.parent_pid := fun pid -> List.assoc_opt pid table);
  Harness.run
  @@ fun env fake ~section ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  section "rule: foot is a terminal" (fun () ->
    Harness.oxctl
      env
      [ "window"; "rules"; "add"; "--app-id"; "^foot$"; "--swallow"; "terminal" ]);
  section "foot arrives" (fun () ->
    Fake_river.add_window ~pid:42 fake ~app_id:(Some "foot"));
  section "mpv arrives - swallows foot" (fun () ->
    Fake_river.add_window ~pid:100 fake ~app_id:(Some "mpv"));
  section "toggle - foot returns" (fun () -> cmd env (Window Toggle_swallow));
  section "toggle - swallows foot again" (fun () -> cmd env (Window Toggle_swallow));
  section "mpv closes - foot returns" (fun () ->
    Fake_river.close_window fake ~app_id:(Some "mpv"))
;;
