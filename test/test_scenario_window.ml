let check_window_focus_zoom ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check window focus zoom"
    h
    [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "window focus prev";
  oxctl "window query";
  oxctl "window zoom";
  oxctl "window query"
;;

let check_window_close ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check window close" h [ "kitty", 1; "firefox", 1 ]
  @@ fun () ->
  section "emacs arrives" (fun () -> Fake_river.add_window fake ~app_id:(Some "emacs"));
  section "close emacs" (fun () -> Fake_river.close_window fake ~app_id:(Some "emacs"));
  oxctl "window query"
;;

let check_late_fixed_hint ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check late fixed hint" h [ "kitty", 1 ]
  @@ fun () ->
  section "galculator arrives without hint" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "galculator"));
  section "late fixed hint" (fun () ->
    Fake_river.send_dimensions_hint
      fake
      ~app_id:(Some "galculator")
      ~min_w:300l
      ~min_h:200l
      ~max_w:300l
      ~max_h:200l);
  oxctl "window list --app-id ^galculator$";
  section "close galculator" (fun () ->
    Fake_river.close_window fake ~app_id:(Some "galculator"))
;;

let check_captured_border ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check captured border" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "border color captured 0xFF0000";
  section "kitty capture starts" (fun () ->
    Fake_river.send_capture_sessions fake ~app_id:(Some "kitty") ~count:2l);
  oxctl "window list --app-id ^kitty$";
  section "kitty capture stops" (fun () ->
    Fake_river.send_capture_sessions fake ~app_id:(Some "kitty") ~count:0l);
  oxctl "border color captured 0x957FB8"
;;

let check_output_capture_sessions ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check output capture sessions" h []
  @@ fun () ->
  oxctl "output list";
  section "output capture starts" (fun () ->
    Fake_river.send_output_capture_sessions fake ~name:"FAKE-1" ~count:1l);
  oxctl "output list";
  section "output capture stops" (fun () ->
    Fake_river.send_output_capture_sessions fake ~name:"FAKE-1" ~count:0l);
  oxctl "output list"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_focus_zoom h;
  check_window_close h;
  check_late_fixed_hint h;
  check_captured_border h;
  check_output_capture_sessions h
;;
