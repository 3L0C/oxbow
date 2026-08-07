let () =
  Harness.run
  @@ fun env fake ~section ->
  let oxctl t =
    let args = String.split_on_char ' ' t in
    section t (fun () -> Harness.oxctl env args)
  in
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
  oxctl "window close --app-id=nope";
  oxctl "window close"
;;
