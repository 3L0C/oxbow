let check_scratchpad_rule ({ Harness.fake; section; oxctl; _ } as h) =
  Harness.with_windows "check scratchpad rule" h [ "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "window rules add --app-id=qalculate --scratchpad=calc --float";
  section "qalculate arrives" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "qalculate"));
  oxctl "scratchpad toggle calc";
  oxctl "window list";
  oxctl "scratchpad toggle calc";
  oxctl "window list";
  oxctl "window scratchpad clear --app-id ^qalculate$";
  oxctl "window list --app-id ^qalculate$";
  oxctl "window rules list";
  oxctl "window rules remove 0";
  section "qalculate closes" (fun () ->
    Fake_river.close_window fake ~app_id:(Some "qalculate"))
;;

let check_scratchpad_add_toggle ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check scratchpad add toggle" h [ "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "scratchpad toggle";
  oxctl "window scratchpad add notes --app-id ^firefox$";
  oxctl "window list --app-id ^firefox$";
  oxctl "scratchpad toggle notes";
  oxctl "window list --app-id ^firefox$";
  oxctl "scratchpad toggle notes";
  oxctl "window list --app-id ^firefox$"
;;

let check_overview_with_stashed ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check overview with stashed" h [ "emacs", 1; "firefox", 1 ]
  @@ fun () ->
  oxctl "window scratchpad add notes --app-id ^firefox$";
  oxctl "scratchpad toggle notes";
  oxctl "output overview";
  oxctl "window list";
  oxctl "output overview";
  oxctl "scratchpad toggle notes"
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_scratchpad_rule h;
  check_scratchpad_add_toggle h;
  check_overview_with_stashed h
;;
