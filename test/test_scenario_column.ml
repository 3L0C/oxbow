let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "firefox"));
  oxctl "layout scrolling";
  oxctl "window column consume";
  oxctl "window focus next";
  oxctl "window zoom"
;;
