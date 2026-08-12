let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "layout floating";
  oxctl "output overview";
  oxctl "output overview";
  oxctl "layout tiling";
  oxctl "output overview";
  oxctl "layout floating";
  oxctl "output overview";
  oxctl "window list"
;;
