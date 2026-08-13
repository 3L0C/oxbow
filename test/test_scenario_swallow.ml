let () =
  let table = [ 100, 42; 42, 7; 7, 1 ] in
  Oxbow_ops.Swallow.parent_pid := fun pid -> List.assoc_opt pid table
;;

let check_swallow_lifecycle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check swallow lifecycle" h []
  @@ fun () ->
  oxctl "window rules add --app-id=^foot$ --swallow=terminal";
  let foot = Harness.spawn ~pid:42 h "foot" in
  let mpv = Harness.spawn ~section:"mpv arrives - swallows foot" ~pid:100 h "mpv" in
  oxctl "window toggle swallow";
  oxctl "window toggle swallow";
  Harness.close ~section:"mpv closes - foot returns" h mpv;
  Harness.close ~section:"foot closes" h foot
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_swallow_lifecycle h
;;
