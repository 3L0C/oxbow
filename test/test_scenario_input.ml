let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  oxctl "input rules mouse --name Logitech.* --natural-scroll enabled --accel-speed 0.5";
  oxctl "input rules mouse --name .* --left-handed enabled";
  oxctl "input rules list";
  oxctl "input rules remove 0";
  oxctl "input rules list";
  oxctl "input rules remove 5"
;;
