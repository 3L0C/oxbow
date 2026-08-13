let check_bind_layout ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check bind layout" h [ "kitty", 1 ]
  @@ fun () ->
  oxctl "bind layout scrolling to Super+s";
  oxctl "unbind Super+s"
;;

let check_bind_window_focus ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check bind window focus" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "bind window focus next to Super+J";
  section "press the bind" (fun () ->
    Fake_river.press_binding fake ~index:(Fake_river.binding_count fake - 1));
  oxctl "unbind Super+J";
  oxctl "window query"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_bind_layout h;
  check_bind_window_focus h
;;
