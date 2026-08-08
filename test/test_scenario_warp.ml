let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "input pointer warp on";
  oxctl "window focus next";
  oxctl "window focus next --no-warp";
  oxctl "input pointer warp off";
  oxctl "window focus next";
  oxctl "window focus next --warp"
;;
