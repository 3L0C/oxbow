let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  oxctl "input pointer follow not-scrolling";
  oxctl "layout scrolling";
  oxctl "window column width +0.3";
  section "in scrolling, hover kitty. expect no focus change" (fun () ->
    Fake_river.send_pointer_hover
      fake
      ~seat:"seat0"
      ~app_id:(Some "kitty")
      ~x:100l
      ~y:500l);
  oxctl "layout floating";
  section "in floating, exit, then reenter kitty. expect focus change" (fun () ->
    Fake_river.send_pointer_hover
      fake
      ~seat:"seat0"
      ~app_id:(Some "emacs")
      ~x:600l
      ~y:520l;
    Fake_river.send_pointer_hover
      fake
      ~seat:"seat0"
      ~app_id:(Some "kitty")
      ~x:120l
      ~y:520l)
;;
