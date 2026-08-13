let check_scrolling_align_centered ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check scrolling align centered"
    h
    [ "kitty", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "layout query";
  oxctl "layout scrolling align centered";
  oxctl "layout scrolling";
  oxctl "window list";
  oxctl "layout scrolling align visible";
  oxctl "layout tiling"
;;

let check_scrolling_focus_scroll ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check scrolling focus scroll"
    h
    [ "mpv", 1; "kitty", 1; "emacs", 1; "firefox", 1; "brave", 1; "feishin", 1 ]
  @@ fun () ->
  oxctl "layout scrolling left";
  oxctl "window focus match --app-id=mpv";
  oxctl "window list";
  oxctl "window focus match --app-id=feishin";
  oxctl "window list";
  oxctl "window focus match --app-id=mpv";
  oxctl "window list";
  oxctl "layout tiling"
;;

let check_scrolling_float_resize_move ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check scrolling float resize move"
    h
    [ "mpv", 1; "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout scrolling left";
  oxctl "window focus match --app-id=mpv";
  oxctl "window resize to 25% 25%";
  oxctl "window move to 75% 75%";
  oxctl "window list";
  oxctl "layout tiling"
;;

let check_scrolling_orientation ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check scrolling orientation"
    h
    [ "mpv", 1; "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout scrolling left";
  oxctl "layout scrolling orientation down";
  oxctl "window list";
  oxctl "layout scrolling orientation right";
  oxctl "window list";
  oxctl "layout scrolling orientation up";
  oxctl "window list";
  oxctl "layout scrolling orientation left";
  oxctl "layout tiling"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_scrolling_align_centered h;
  check_scrolling_focus_scroll h;
  check_scrolling_float_resize_move h;
  check_scrolling_orientation h
;;
