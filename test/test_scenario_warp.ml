let check_pointer_warp_on ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check pointer warp on" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "input pointer warp on";
  oxctl "window focus next";
  oxctl "window focus next --no-warp"
;;

let check_pointer_warp_off ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check pointer warp off" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "input pointer warp off";
  oxctl "window focus next";
  oxctl "window focus next --warp"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_pointer_warp_on h;
  check_pointer_warp_off h
;;
