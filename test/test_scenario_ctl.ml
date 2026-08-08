let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty"));
  oxctl "window rules add --app-id ^mpv$ --float --tags 3";
  section "mpv arrives floating on tag 3" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  oxctl "window rules list";
  oxctl "window rules remove 0";
  oxctl "window rules remove 7";
  section "third window" (fun () -> Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "gaps inner 4";
  oxctl "gaps inner 6 --output FAKE-1";
  oxctl "gaps inner 8 --all";
  oxctl "window list";
  oxctl "window list --json"
;;
