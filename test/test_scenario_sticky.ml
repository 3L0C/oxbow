let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "window tag set 2";
  oxctl "window toggle sticky all";
  oxctl "tag view 2";
  oxctl "window sticky occupied";
  oxctl "tag view 3";
  oxctl "window query";
  oxctl "window sticky off --app-id=kitty";
  oxctl "tag view 1";
  section "add windows" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "mpv");
    Fake_river.add_window fake ~app_id:(Some "firefox"));
  oxctl "window tag set 2";
  oxctl "window focus match --app-id=kitty";
  oxctl "window list";
  oxctl "window sticky occupied --app-id=mpv";
  oxctl "tag view 2";
  oxctl "window list";
  oxctl "tag view 1";
  oxctl "window list"
;;
