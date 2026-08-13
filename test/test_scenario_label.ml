let check_window_label_add_remove ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window label add remove" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=kitty";
  oxctl "window label add scratch";
  oxctl "window label add term";
  oxctl "window label add scratch";
  oxctl "window list";
  oxctl "window label remove scratch";
  oxctl "window list"
;;

let check_label_empty_rejected ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check label empty rejected" h []
  @@ fun () ->
  oxctl "window label add ";
  oxctl "output label add "
;;

let check_window_focus_by_label ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window focus by label" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=kitty";
  oxctl "window label add term";
  oxctl "window focus match --app-id=emacs";
  oxctl "window label add term";
  oxctl "window focus match --label=term";
  oxctl "window focus match --cycle --label=term";
  oxctl "window list --label=te.*";
  oxctl "window list --label=none"
;;

let check_window_label_as_rule ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check window label as rule" h []
  @@ fun () ->
  oxctl "window rules add --label-as=video_player --app-id=mpv";
  oxctl "window rules add --label-as=browser --app-id=firefox";
  section "firefox and mpv arrive" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "firefox");
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  oxctl "window list --label=video_player";
  oxctl "window list --label=browser";
  oxctl "window rules remove 0";
  oxctl "window rules remove 0";
  oxctl "window rules list";
  section "close firefox and mpv" (fun () ->
    Fake_river.close_window fake ~app_id:(Some "firefox");
    Fake_river.close_window fake ~app_id:(Some "mpv"))
;;

let check_output_label_add ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check output label add" h []
  @@ fun () ->
  oxctl "output label add main";
  oxctl "output list";
  oxctl "output label remove main";
  oxctl "output list"
;;

let check_output_focus_by_label ({ Harness.oxctl; _ } as h) =
  Harness.with_outputs
    "check output focus by label"
    h
    [ "FAKE-2", 1920l, 0l; "FAKE-3", 3840l, 0l ]
  @@ fun () ->
  oxctl "output label add --name=FAKE-1 first";
  oxctl "output label add --name=FAKE-2 second";
  oxctl "output label add --name=FAKE-3 third";
  oxctl "output focus match --label=second";
  oxctl "output list";
  oxctl "output focus match --label=first";
  oxctl "output list";
  oxctl "output focus match --label=third";
  oxctl "output list";
  oxctl "output label remove --name=FAKE-1 first"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_label_add_remove h;
  check_label_empty_rejected h;
  check_window_focus_by_label h;
  check_window_label_as_rule h;
  check_output_label_add h;
  check_output_focus_by_label h
;;
