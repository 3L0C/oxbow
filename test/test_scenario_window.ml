let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "firefox"));
  oxctl "window focus prev";
  oxctl "window zoom";
  section "close emacs" (fun () -> Fake_river.close_window fake ~app_id:(Some "emacs"));
  oxctl "window query";
  section "galculator arrives without hint" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "galculator"));
  section "late fixed hint" (fun () ->
    Fake_river.send_dimensions_hint
      fake
      ~app_id:(Some "galculator")
      ~min_w:300l
      ~min_h:200l
      ~max_w:300l
      ~max_h:200l);
  oxctl "window list --app-id ^galculator$"
;;
