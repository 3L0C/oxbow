let check_toggle_sticky_all ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check toggle sticky all" h [ "kitty", 1; "emacs", 2 ]
  @@ fun () ->
  oxctl "window toggle sticky all";
  oxctl "tag view 2";
  oxctl "window list";
  oxctl "window toggle sticky all";
  oxctl "tag view 1"
;;

let check_sticky_occupied ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check sticky occupied" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window tag set 2";
  oxctl "window sticky occupied";
  oxctl "tag view 2";
  oxctl "window list";
  oxctl "tag view 3";
  oxctl "window query";
  oxctl "window sticky off --app-id=kitty";
  oxctl "tag view 1"
;;

let check_sticky_occupied_match ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check sticky occupied match"
    h
    [ "kitty", 1; "mpv", 1; "firefox", 2 ]
  @@ fun () ->
  oxctl "window focus match --app-id=kitty";
  oxctl "window sticky occupied --app-id=mpv";
  oxctl "tag view 2";
  oxctl "window list";
  oxctl "tag view 1";
  oxctl "window list";
  oxctl "window sticky off --app-id=mpv"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_toggle_sticky_all h;
  check_sticky_occupied h;
  check_sticky_occupied_match h
;;
