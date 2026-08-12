let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "window focus match --app-id=kitty";
  oxctl "window label add scratch";
  oxctl "window label add term";
  oxctl "window label add scratch";
  oxctl "window list";
  oxctl "window label remove scratch";
  oxctl "window list";
  oxctl "output label add main";
  oxctl "output list";
  oxctl "window label add ";
  oxctl "output label add ";
  oxctl "window focus match --app-id=emacs";
  oxctl "window label add term";
  oxctl "window focus match --label=term";
  oxctl "window focus match --cycle --label=term";
  oxctl "window list --label=te.*";
  oxctl "window list --label=none";
  oxctl "window rules add --label-as=video_player --app-id=mpv";
  oxctl "window rules add --label-as=browser --app-id=firefox";
  section "test label-as rule" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "firefox");
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  oxctl "window list --label=video_player";
  oxctl "window list --label=browser";
  section "test output labels" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-2";
    Fake_river.add_output fake ~name:"FAKE-3");
  oxctl "output label add --name=FAKE-1 first";
  oxctl "output label add --name=FAKE-2 second";
  oxctl "output label add --name=FAKE-3 third";
  oxctl "output focus match --label=second";
  oxctl "output list";
  oxctl "output focus match --label=first";
  oxctl "output list";
  oxctl "output focus match --label=third";
  oxctl "output list"
;;
