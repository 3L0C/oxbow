let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "bind layout scrolling to Super+s";
  oxctl "bind window focus next to Super+J";
  section "press the bind" (fun () ->
    Fake_river.press_binding fake ~index:(Fake_river.binding_count fake - 1));
  oxctl "unbind Super+J";
  oxctl "window query"
;;
