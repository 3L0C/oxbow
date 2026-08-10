let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "firefox");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  section "drag mpv, option off" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:1500l ~y:500l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list";
  oxctl "window toggle floating";
  oxctl "window drag retile enabled";
  section "drag mpv onto the master" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release over firefox" (fun () ->
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
  oxctl "window list";
  oxctl "layout scrolling left";
  oxctl "window focus match --app-id=emacs";
  oxctl "window column consume";
  oxctl "window list";
  section "drag firefox out of the column" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "firefox"));
  oxctl "window move drag";
  section "release right of mpv" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:1900l ~y:500l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list";
  oxctl "layout scrolling orientation down";
  oxctl "window list";
  section "drag mpv in the vertical strip" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window move drag";
  section "release in the upper half of firefox" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:50l ~dy:50l;
    Fake_river.send_pointer_position fake ~seat:"seat0" ~x:200l ~y:700l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list";
  section "inkscape arrives with a min hint" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "inkscape");
    Fake_river.send_dimensions_hint
      fake
      ~app_id:(Some "inkscape")
      ~min_w:300l
      ~min_h:200l
      ~max_w:0l
      ~max_h:0l);
  section "grab the top-left corner" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "inkscape"));
  oxctl "window resize drag";
  section "overshoot the min" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:2000l ~dy:2000l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list";
  section "grab the bottom-left corner of mpv, no hints" (fun () ->
    Fake_river.send_pointer_enter fake ~seat:"seat0" ~app_id:(Some "mpv"));
  oxctl "window resize drag";
  section "overshoot the floor" (fun () ->
    Fake_river.send_op_delta fake ~seat:"seat0" ~dx:2000l ~dy:2000l;
    Fake_river.send_op_release fake ~seat:"seat0");
  oxctl "window list"
;;
