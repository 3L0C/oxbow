let () =
  let table = [ 100, 42; 42, 7; 7, 1 ] in
  Oxbow_ops.Swallow.parent_pid := fun pid -> List.assoc_opt pid table
;;

let check_swallow_lifecycle ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check swallow lifecycle" h []
  @@ fun () ->
  oxctl "window rules add --app-id=^foot$ --swallow=terminal";
  section "foot arrives" (fun () ->
    Fake_river.add_window ~pid:42 fake ~app_id:(Some "foot"));
  section "mpv arrives - swallows foot" (fun () ->
    Fake_river.add_window ~pid:100 fake ~app_id:(Some "mpv"));
  oxctl "window toggle swallow";
  oxctl "window toggle swallow";
  section "mpv closes - foot returns" (fun () ->
    Fake_river.close_window fake ~app_id:(Some "mpv"));
  section "foot closes" (fun () -> Fake_river.close_window fake ~app_id:(Some "foot"))
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_swallow_lifecycle h
;;
