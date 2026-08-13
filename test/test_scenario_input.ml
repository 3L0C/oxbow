let check_input_rules_add ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check input rules add" h []
  @@ fun () ->
  oxctl "input rules mouse --name Logitech.* --natural-scroll enabled --accel-speed 0.5";
  oxctl "input rules mouse --name .* --left-handed enabled";
  oxctl "input rules list"
;;

let check_input_rules_remove ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check input rules remove" h []
  @@ fun () ->
  oxctl "input rules mouse --name Logitech.* --natural-scroll enabled";
  oxctl "input rules mouse --name .* --left-handed enabled";
  oxctl "input rules remove 0";
  oxctl "input rules list";
  oxctl "input rules remove 5"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_input_rules_add h;
  check_input_rules_remove h
;;
