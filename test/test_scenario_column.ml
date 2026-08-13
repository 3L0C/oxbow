let check_column_consume ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check column consume" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout scrolling";
  oxctl "window column consume";
  oxctl "window list"
;;

let check_column_focus_zoom ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check column focus zoom"
    h
    [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout scrolling";
  oxctl "window column consume";
  oxctl "window focus next";
  oxctl "window zoom";
  oxctl "window list"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_column_consume h;
  check_column_focus_zoom h
;;
