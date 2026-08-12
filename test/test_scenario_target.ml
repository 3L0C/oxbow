let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "foot");
    Fake_river.add_window fake ~app_id:(Some "mpv");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "window close --app-id=mpv";
  oxctl "window focus match --app-id=kitty";
  oxctl "window label add scratch";
  oxctl "window focus match --app-id=foot";
  oxctl "window label add scratch";
  oxctl "window tag set --app-id=emacs --follow 3";
  oxctl "window list";
  oxctl "window tag set --label=scratch --all --follow 2";
  oxctl "window list";
  oxctl "window tag set --app-id=.* --cycle 5";
  oxctl "window list";
  oxctl "window tag set --app-id ^(emacs|mpv)$ --cycle 6";
  oxctl "window list";
  oxctl "window focus match --app-id=.* --cycle";
  oxctl "window list";
  oxctl "window focus match --app-id=.* --cycle";
  oxctl "window list";
  oxctl "window focus match --app-id=.* --cycle";
  oxctl "window list";
  oxctl "window toggle floating --app-id=kitty";
  oxctl "window list";
  oxctl "window toggle fullscreen --app-id=kitty --all";
  oxctl "window label add seen --app-id=emacs";
  oxctl "window list";
  oxctl "window close --all";
  oxctl "window close --app-id=nope";
  oxctl "window close"
;;
