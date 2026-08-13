let check_window_rules_apply ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check window rules apply" h [ "kitty", 1 ]
  @@ fun () ->
  oxctl "window rules add --app-id ^mpv$ --float --tags 3";
  section "mpv arrives floating on tag 3" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  oxctl "window list --fields app_id,tags,presentation";
  oxctl "window rules list";
  oxctl "window rules remove 0";
  section "close mpv" (fun () -> Fake_river.close_window fake ~app_id:(Some "mpv"))
;;

let check_window_rules_errors ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window rules errors" h []
  @@ fun () ->
  oxctl "window rules add --app-id=[ --float";
  oxctl "window rules remove 7"
;;

let check_gaps ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check gaps" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "gaps inner 4";
  oxctl "gaps inner 6 --output FAKE-1";
  oxctl "gaps inner 8 --all"
;;

let check_window_list ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window list" h [ "kitty", 1; "mpv", 2 ]
  @@ fun () ->
  oxctl "window list";
  oxctl "window list --fields id,app_id";
  oxctl "window list --json"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_rules_apply h;
  check_window_rules_errors h;
  check_gaps h;
  check_window_list h
;;
