let () =
  let table = [ 100, 42; 42, 7; 7, 1 ] in
  Oxbow_ops.Swallow.parent_pid := fun pid -> List.assoc_opt pid table
;;

let check_swallow_lifecycle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check swallow lifecycle" h []
  @@ fun () ->
  oxctl "window rules add --app-id=^foot$ --swallow=terminal";
  let foot = Harness.spawn ~pid:42 h "foot" in
  let mpv = Harness.spawn ~section:"mpv arrives; swallows foot" ~pid:100 h "mpv" in
  oxctl "window toggle swallow";
  oxctl "window toggle swallow";
  Harness.close ~section:"mpv closes; foot returns" h mpv;
  Harness.close ~section:"foot closes" h foot
;;

let check_unswallow_floating ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check unswallow floating layout" h []
  @@ fun () ->
  oxctl "window rules add --app-id=^foot$ --swallow=terminal";
  oxctl "layout scrolling";
  let foot = Harness.spawn ~pid:42 h "foot" in
  let mpv = Harness.spawn ~section:"mpv arrives; swallows foot" ~pid:100 h "mpv" in
  oxctl "layout floating";
  oxctl "window toggle swallow";
  Harness.close h mpv;
  Harness.close h foot
;;

let check_floating_swallow ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check floating swallow" h []
  @@ fun () ->
  oxctl "window rules add --app-id=^foot$ --swallow=terminal";
  let foot = Harness.spawn ~pid:42 h "foot" in
  oxctl "window toggle floating";
  let mpv =
    Harness.spawn ~section:"mpv arrives; swallows floating foot" ~pid:100 h "mpv"
  in
  oxctl "window list";
  Harness.close ~section:"mpv closes; foot returns" h mpv;
  oxctl "window list";
  Harness.close h foot
;;

let check_swallow_cross_output ({ Harness.oxctl; _ } as h) =
  Harness.with_outputs "check swallow cross output" h [ "FAKE-2", 1920l, 0l ]
  @@ fun () ->
  Harness.with_windows "check swallow cross output" h []
  @@ fun () ->
  oxctl "window rules add --app-id=^foot$ --swallow=terminal";
  let foot = Harness.spawn ~pid:42 h "foot" in
  let mpv = Harness.spawn ~section:"mpv arrives; swallows foot" ~pid:100 h "mpv" in
  oxctl "window send to FAKE-2";
  oxctl "window list";
  oxctl "window toggle swallow";
  oxctl "window list";
  Harness.close ~section:"mpv closes" h mpv;
  Harness.close h foot
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_swallow_lifecycle h;
  check_unswallow_floating h;
  check_floating_swallow h;
  check_swallow_cross_output h
;;
