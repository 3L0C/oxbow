let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  section "second output at x=1920" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-2" ~x:1920l);
  oxctl "window send to FAKE-2";
  oxctl "output focus next";
  oxctl "layout floating";
  oxctl "output focus next";
  oxctl "layout floating";
  oxctl "output swap tags";
  oxctl "window list";
  oxctl "window resize to 800 600 --app-id ^kitty$";
  oxctl "window move to 100 100 --app-id ^kitty$";
  oxctl "output swap tags";
  oxctl "output swap tags";
  oxctl "output focus next";
  oxctl "layout tiling";
  oxctl "window toggle floating --app-id ^kitty$";
  oxctl "window toggle floating --app-id ^kitty$";
  oxctl "window list"
;;
