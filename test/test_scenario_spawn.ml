let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "firefox");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position next";
  section "spawn kitty" (fun () -> Fake_river.add_window fake ~app_id:(Some "kitty"));
  section "close kitty" (fun () -> Fake_river.close_window fake ~app_id:(Some "kitty"));
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position prev";
  section "spawn kitty" (fun () -> Fake_river.add_window fake ~app_id:(Some "kitty"));
  section "close kitty" (fun () -> Fake_river.close_window fake ~app_id:(Some "kitty"));
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position end";
  oxctl "window spawn focus disabled";
  section "spawn kitty" (fun () -> Fake_river.add_window fake ~app_id:(Some "kitty"));
  oxctl "window list";
  section "close kitty" (fun () -> Fake_river.close_window fake ~app_id:(Some "kitty"));
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position prev";
  oxctl "window rules add --app-id=kitty --spawn-position=end --spawn-focus=disabled";
  section "spawn kitty" (fun () -> Fake_river.add_window fake ~app_id:(Some "kitty"));
  oxctl "window list";
  section "close kitty" (fun () -> Fake_river.close_window fake ~app_id:(Some "kitty"))
;;
