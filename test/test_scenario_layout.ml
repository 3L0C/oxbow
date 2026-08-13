let check_tiling_mfact ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check tiling mfact" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout tiling mfact +0.05";
  oxctl "layout tiling query";
  oxctl "layout tiling mfact 0.55"
;;

let check_tiling_scheme ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check tiling scheme" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout tiling scheme monocle";
  oxctl "layout tiling scheme deck";
  let mpv = ref None in
  let feishin = ref None in
  section "check tiling scheme spawn under deck" (fun () ->
    mpv := Some (Fake_river.spawn_window fake ~app_id:(Some "mpv"));
    feishin := Some (Fake_river.spawn_window fake ~app_id:(Some "feishin")));
  oxctl "window list";
  section "check tiling scheme spawn teardown" (fun () ->
    Option.iter (Fake_river.close fake) !feishin;
    Option.iter (Fake_river.close fake) !mpv);
  oxctl "layout tiling scheme even"
;;

let check_layout_select ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check layout select" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout floating";
  oxctl "layout scrolling";
  oxctl "layout query";
  oxctl "layout tiling"
;;

let check_overview_toggle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview toggle" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout scrolling";
  oxctl "output overview";
  oxctl "window focus prev";
  oxctl "output overview";
  oxctl "layout tiling"
;;

let check_floating_seed ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check floating seed" h [ "kitty", 1 ]
  @@ fun () ->
  oxctl "layout floating seed 25%";
  let chromium = ref None in
  section "check floating seed spawn - no float memory" (fun () ->
    chromium := Some (Fake_river.spawn_window fake ~app_id:(Some "chromium")));
  oxctl "window toggle floating --app-id ^chromium$";
  oxctl "window list";
  section "check floating seed teardown" (fun () ->
    Option.iter (Fake_river.close fake) !chromium);
  oxctl "layout floating seed 50%"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_tiling_mfact h;
  check_tiling_scheme h;
  check_layout_select h;
  check_overview_toggle h;
  check_floating_seed h
;;
