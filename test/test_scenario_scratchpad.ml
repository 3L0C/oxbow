let () =
  Harness.run
  @@ fun _env fake ~section ~oxctl ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "emacs");
    Fake_river.add_window fake ~app_id:(Some "firefox"));
  oxctl "window rules add --app-id=qalculate --scratchpad=calc --float";
  section "qalculate arrives" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "qalculate"));
  oxctl "scratchpad toggle calc";
  oxctl "window list";
  oxctl "scratchpad toggle calc";
  oxctl "window list";
  oxctl "scratchpad toggle";
  oxctl "window list --app-id ^qalculate$";
  oxctl "window scratchpad clear --app-id ^qalculate$";
  oxctl "window list --app-id ^qalculate$";
  oxctl "window scratchpad add notes --app-id ^firefox$";
  oxctl "window list --app-id ^firefox$";
  oxctl "scratchpad toggle notes";
  oxctl "output overview";
  oxctl "window list"
;;
