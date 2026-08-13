let check_window_send_to_output ({ Harness.oxctl; _ } as h) =
  Harness.with_outputs "check window send to output" h [ "FAKE-2", 1920l, 0l ]
  @@ fun () ->
  Harness.with_windows "check window send to output" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window send to FAKE-2";
  oxctl "window list"
;;

let check_output_swap_tags ({ Harness.oxctl; _ } as h) =
  Harness.with_outputs "check output swap tags" h [ "FAKE-2", 1920l, 0l ]
  @@ fun () ->
  Harness.with_windows "check output swap tags" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window send to FAKE-2";
  oxctl "output swap tags";
  oxctl "window list";
  oxctl "output swap tags";
  oxctl "window list"
;;

let check_floating_move_resize ({ Harness.oxctl; _ } as h) =
  Harness.with_outputs "check floating move resize" h [ "FAKE-2", 1920l, 0l ]
  @@ fun () ->
  Harness.with_windows "check floating move resize" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window send to FAKE-2";
  oxctl "output focus next";
  oxctl "layout floating";
  oxctl "output focus next";
  oxctl "layout floating";
  oxctl "window resize to 800 600 --app-id ^kitty$";
  oxctl "window move to 100 100 --app-id ^kitty$";
  oxctl "output swap tags";
  oxctl "window list";
  oxctl "layout tiling"
;;

let check_window_toggle_floating ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check window toggle floating" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "window toggle floating --app-id ^kitty$";
  oxctl "window list";
  oxctl "window resize to 800 600 --app-id ^kitty$";
  oxctl "window move to 100 100 --app-id ^kitty$";
  oxctl "window list";
  oxctl "window toggle floating --app-id ^kitty$";
  oxctl "window list";
  oxctl "window toggle floating --app-id ^kitty$";
  oxctl "window list"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_send_to_output h;
  check_output_swap_tags h;
  check_floating_move_resize h;
  check_window_toggle_floating h
;;
