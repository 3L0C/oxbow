let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
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
  oxctl "window query"
;;
