let check_tiling_mfact ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check tiling mfact" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout tiling mfact +0.05";
  oxctl "layout tiling query"
;;

let check_tiling_scheme ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check tiling scheme" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout tiling scheme monocle";
  oxctl "layout tiling scheme deck";
  let mpv = Harness.spawn ~section:"mpv arrives under deck" h "mpv" in
  let feishin = Harness.spawn ~section:"feishin arrives under deck" h "feishin" in
  oxctl "window list";
  Harness.close h feishin;
  Harness.close h mpv
;;

let check_layout_select ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check layout select" h [ "kitty", 1; "emacs", 1 ]
  @@ fun () ->
  oxctl "layout floating";
  oxctl "layout scrolling";
  oxctl "layout query"
;;

let check_overview_toggle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview toggle" h [ "kitty", 1; "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "layout scrolling";
  oxctl "output overview";
  oxctl "window focus prev";
  oxctl "output overview"
;;

let check_floating_seed ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check floating seed" h [ "kitty", 1 ]
  @@ fun () ->
  oxctl "layout floating seed 25%";
  let chromium =
    Harness.spawn ~section:"chromium arrives - no float memory" h "chromium"
  in
  oxctl "window toggle floating --app-id ^chromium$";
  oxctl "window list";
  Harness.close h chromium
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
