let check_scrolling_hover_no_follow ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check scrolling hover no follow" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
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
  oxctl "layout tiling"
;;

let check_floating_hover_follow ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check floating hover follow" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "input pointer follow not-scrolling";
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
      ~y:520l);
  oxctl "layout tiling"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_scrolling_hover_no_follow h;
  check_floating_hover_follow h
;;
