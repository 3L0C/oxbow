let check_window_focus_match ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window focus match" h [ "kitty", 1; "foot", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=kitty";
  oxctl "window list";
  oxctl "window focus match --app-id=foot";
  oxctl "window list"
;;

let check_window_focus_cycle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window focus cycle" h [ "kitty", 1; "foot", 1; "emacs", 2 ]
  @@ fun () ->
  oxctl "window focus match --app-id=.* --cycle";
  oxctl "window list";
  oxctl "window focus match --app-id=.* --cycle";
  oxctl "window list";
  oxctl "window focus match --app-id=.* --cycle";
  oxctl "window list"
;;

let check_window_label_add ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window label add" h [ "kitty", 1; "foot", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=kitty";
  oxctl "window label add scratch";
  oxctl "window focus match --app-id=foot";
  oxctl "window label add scratch";
  oxctl "window label add seen --app-id=emacs";
  oxctl "window list"
;;

let check_window_tag_set ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check window tag set"
    h
    [ "kitty", 1; "foot", 1; "mpv", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window label add scratch --app-id=kitty";
  oxctl "window label add scratch --app-id=foot";
  oxctl "window tag set --app-id=emacs --follow 3";
  oxctl "window list";
  oxctl "window tag set --label=scratch --all --follow 2";
  oxctl "window list";
  oxctl "window tag set --app-id=.* --cycle 5";
  oxctl "window list";
  oxctl "window tag set --app-id ^(emacs|mpv)$ --cycle 6";
  oxctl "window list"
;;

let check_window_toggle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window toggle" h [ "kitty", 1 ]
  @@ fun () ->
  oxctl "window toggle floating --app-id=kitty";
  oxctl "window list";
  oxctl "window toggle fullscreen --app-id=kitty --all"
;;

let check_window_close ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check window close" h []
  @@ fun () ->
  section "spawn kitty and mpv" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  oxctl "window close --app-id=mpv";
  section "mpv obeys close" (fun () -> Fake_river.close_window fake ~app_id:(Some "mpv"));
  oxctl "window close --all";
  oxctl "window close --app-id=nope";
  oxctl "window close";
  section "kitty obeys close" (fun () ->
    Fake_river.close_window fake ~app_id:(Some "kitty"));
  oxctl "window list"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_focus_match h;
  check_window_focus_cycle h;
  check_window_label_add h;
  check_window_tag_set h;
  check_window_toggle h;
  check_window_close h
;;
