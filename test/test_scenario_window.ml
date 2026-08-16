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

let check_window_close ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window close" h [ "kitty", 1; "firefox", 1 ]
  @@ fun () ->
  let emacs = Harness.spawn h "emacs" in
  Harness.close h emacs;
  oxctl "window query"
;;

let check_late_fixed_hint ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check late fixed hint" h [ "kitty", 1 ]
  @@ fun () ->
  let galculator =
    Harness.spawn ~section:"galculator arrives without hint" h "galculator"
  in
  section "late fixed hint" (fun () ->
    Fake_river.send_dimensions_hint
      fake
      ~app_id:(Some "galculator")
      ~min_w:300l
      ~min_h:200l
      ~max_w:300l
      ~max_h:200l);
  oxctl "window list --app-id ^galculator$";
  Harness.close h galculator
;;

let check_captured_border ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check captured border" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "border color captured 0xFF0000";
  section "kitty capture starts" (fun () ->
    Fake_river.send_capture_sessions fake ~app_id:(Some "kitty") ~count:2l);
  oxctl "window list --app-id ^kitty$";
  section "kitty capture stops" (fun () ->
    Fake_river.send_capture_sessions fake ~app_id:(Some "kitty") ~count:0l)
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

let check_floating_rules ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check floating rules" h []
  @@ fun () ->
  oxctl "window rules add --app-id=.* --move-to=25%,25% --resize-to=50%,50%";
  oxctl "window rules list";
  Harness.spawn ~section:"spawn kitty" h "kitty" |> Harness.close h
;;

let check_stale_dimensions_echo ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check stale dimensions echo" h []
  @@ fun () ->
  let kitty = Harness.spawn h "kitty" in
  oxctl "window toggle floating";
  section "stale echo arrives" (fun () ->
    Fake_river.send_dimensions fake ~app_id:(Some "kitty") ~width:1872l ~height:1032l);
  oxctl "window list";
  Harness.close h kitty
;;

let check_spatial_focus_floats ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check spatial focus floats" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window toggle floating";
  oxctl "window move to 75% 25%";
  oxctl "window focus left";
  oxctl "window query";
  oxctl "window focus right";
  oxctl "window query"
;;

let check_repeated_stale_echo ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check repeated stale echo" h []
  @@ fun () ->
  let kitty = Harness.spawn h "kitty" in
  oxctl "window toggle floating";
  section "stale report arrives twice" (fun () ->
    Fake_river.send_dimensions fake ~app_id:(Some "kitty") ~width:1872l ~height:1032l;
    Fake_river.send_dimensions fake ~app_id:(Some "kitty") ~width:1872l ~height:1032l);
  section "float ack arrives" (fun () ->
    Fake_river.send_dimensions fake ~app_id:(Some "kitty") ~width:960l ~height:540l);
  section "client resizes, then returns to an old ask" (fun () ->
    Fake_river.send_dimensions fake ~app_id:(Some "kitty") ~width:800l ~height:600l;
    Fake_river.send_dimensions fake ~app_id:(Some "kitty") ~width:1872l ~height:1032l);
  Harness.close h kitty
;;

let check_fit_to_output ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check fit to output" h [ "emacs", 1 ]
  @@ fun () ->
  oxctl "window resize to 110% 110%";
  oxctl "window toggle floating";
  oxctl "window toggle floating"
;;

let check_floating_transitions ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check fit to output" h [ "emacs", 1; "kitty", 2 ]
  @@ fun () ->
  oxctl "window resize to 50% 50% --app-id=^emacs$";
  oxctl "window move to 25% 25% --app-id=^emacs$";
  oxctl "window toggle floating --app-id=^emacs$";
  oxctl "window resize to 50% 50% --app-id=^kitty$";
  oxctl "window move to 50% 50% --app-id=^kitty$";
  oxctl "window toggle floating --app-id=^kitty$";
  oxctl "tag view 1,2";
  oxctl "layout floating";
  oxctl "layout tiling"
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
  check_output_capture_sessions h;
  check_floating_rules h;
  check_stale_dimensions_echo h;
  check_spatial_focus_floats h;
  check_repeated_stale_echo h;
  check_fit_to_output h;
  check_floating_transitions h
;;
