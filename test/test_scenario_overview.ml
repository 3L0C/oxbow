let check_overview_toggle_floating ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview toggle floating" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout floating";
  oxctl "output overview";
  oxctl "output overview";
  oxctl "window list";
  oxctl "layout tiling"
;;

let check_overview_layout_switch ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview layout switch" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout tiling";
  oxctl "output overview";
  oxctl "layout floating";
  oxctl "output overview";
  oxctl "window list";
  oxctl "layout tiling"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_overview_toggle_floating h;
  check_overview_layout_switch h
;;
