let check_move_drag_floats ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check move drag floats" h [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  section "drag mpv, retile off" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:1500l ~y:500l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list";
  oxctl "window toggle floating";
  oxctl "window list"
;;

let check_move_drag_retile ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check move drag retile" h [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "window drag retile enabled";
  section "drag mpv" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release in the upper half of firefox" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:1500l ~y:500l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list";
  section "drag mpv again" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release in the lower half of firefox" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:1500l ~y:900l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list"
;;

let check_move_drag_scrolling_column ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows
    "check move drag scrolling column"
    h
    [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "layout scrolling left";
  oxctl "window focus match --app-id=emacs";
  oxctl "window column consume";
  oxctl "window list";
  section "drag firefox out of the column" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "firefox"));
  oxctl "window move drag";
  section "release right of the column" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:1900l ~y:500l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list"
;;

let check_move_drag_scrolling_vertical ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows
    "check move drag scrolling vertical"
    h
    [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "layout scrolling left";
  oxctl "layout scrolling orientation down";
  oxctl "window list";
  section "drag mpv in the vertical strip" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release in the upper half of firefox" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:200l ~y:700l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list"
;;

let check_resize_drag_min_hint ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check resize drag min hint" h [ "inkscape", 1 ]
  @@ fun () ->
  section "inkscape reports a min hint" (fun () ->
    Fake_river.send_dimensions_hint
      fake
      ~app_id:(Some "inkscape")
      ~min_w:300l
      ~min_h:200l
      ~max_w:0l
      ~max_h:0l);
  section "grab the top-left corner" (fun () ->
    Fake_river.send_pointer_hover
      fake
      ~seat:"seat0"
      ~app_id:(Some "inkscape")
      ~x:30l
      ~y:30l);
  oxctl "window resize drag";
  section "overshoot the min" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:2000l ~dy:2000l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list"
;;

let check_resize_drag_floor ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check resize drag floor" h [ "mpv", 1 ]
  @@ fun () ->
  section "grab the bottom-left corner, no hints" (fun () ->
    Fake_river.send_pointer_hover fake ~seat:"seat0" ~app_id:(Some "mpv") ~x:30l ~y:900l);
  oxctl "window resize drag";
  section "overshoot the floor" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:2000l ~dy:2000l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_move_drag_floats h;
  check_move_drag_retile h;
  check_move_drag_scrolling_column h;
  check_move_drag_scrolling_vertical h;
  check_resize_drag_min_hint h;
  check_resize_drag_floor h
;;
