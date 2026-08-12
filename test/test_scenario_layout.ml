let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "firefox"));
  oxctl "layout tiling mfact +0.05";
  oxctl "layout tiling scheme monocle";
  oxctl "layout tiling scheme deck";
  section "spawn - mpv and feishin" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "mpv");
    Fake_river.add_window fake ~app_id:(Some "feishin"));
  oxctl "layout floating";
  oxctl "layout scrolling";
  oxctl "output overview";
  oxctl "window focus prev";
  oxctl "layout query";
  oxctl "output overview";
  oxctl "layout floating seed 25%";
  section "chromium arrives - no float memory" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "chromium"));
  oxctl "window toggle floating --app-id ^chromium$"
;;
