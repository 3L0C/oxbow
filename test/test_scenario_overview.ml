let check_overview_toggle_floating ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview toggle floating" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout floating";
  oxctl "output overview";
  oxctl "output overview";
  oxctl "window list"
;;

let check_overview_layout_switch ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview layout switch" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout floating";
  oxctl "window resize to 800 600 --app-id ^kitty$";
  oxctl "window move to 100 100 --app-id ^kitty$";
  oxctl "window resize to 640 480 --app-id ^emacs$";
  oxctl "window move to 300 400 --app-id ^emacs$";
  oxctl "layout tiling";
  oxctl "output overview";
  oxctl "layout floating";
  oxctl "output overview";
  oxctl "window list"
;;

let check_overview_gaps_inherit ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview gaps inherit" h []
  @@ fun () ->
  let kitty = Harness.spawn h "kitty" in
  let emacs = Harness.spawn h "emacs" in
  oxctl "output overview";
  oxctl "output overview";
  oxctl "gaps overview 0 --all";
  let output2 = Harness.spawn_output ~x:1920l ~y:0l h "FAKE-2" in
  oxctl "window send to --app-id=^(kitty|emacs)$ --all FAKE-2";
  oxctl "output focus match --name=^FAKE-2$";
  oxctl "output overview";
  Harness.remove_output h output2;
  Harness.close h kitty;
  Harness.close h emacs
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_overview_toggle_floating h;
  check_overview_layout_switch h;
  check_overview_gaps_inherit h
;;
