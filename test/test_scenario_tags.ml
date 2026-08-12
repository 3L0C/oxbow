let check_window_tag_set ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window tag set" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window tag set 2";
  oxctl "tag query"
;;

let check_tag_view ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check tag view" h [ "kitty", 1; "kitty", 2 ]
  @@ fun () ->
  oxctl "tag view 2";
  oxctl "tag prev";
  oxctl "tag query"
;;

let check_tag_toggle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check tag toggle" h [ "kitty", 1; "mpv", 2 ]
  @@ fun () ->
  oxctl "tag toggle 2";
  oxctl "tag query"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_tag_set h;
  check_tag_view h;
  check_tag_toggle h
;;
