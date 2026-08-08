let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "mpv");
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "firefox");
    Fake_river.add_window fake ~app_id:(Some "brave");
    Fake_river.add_window fake ~app_id:(Some "feishin"));
  oxctl "window list";
  oxctl "layout scrolling left";
  oxctl "window focus match --app-id=mpv";
  oxctl "window resize to 25% 25%";
  oxctl "window move to 75% 75%";
  oxctl "window list";
  oxctl "window focus match --app-id=feishin";
  oxctl "window list";
  oxctl "window focus match --app-id=mpv";
  oxctl "window list"
;;
