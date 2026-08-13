let with_kitty { Harness.fake; section; _ } body =
  let kitty = ref None in
  section "spawn kitty" (fun () ->
    kitty := Some (Fake_river.spawn_window fake ~app_id:(Some "kitty")));
  body ();
  section "close kitty" (fun () -> Option.iter (Fake_river.close fake) !kitty)
;;

let check_spawn_position_next ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check spawn position next"
    h
    [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position next";
  with_kitty h (fun () -> oxctl "window list")
;;

let check_spawn_position_prev ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check spawn position prev"
    h
    [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position prev";
  with_kitty h (fun () -> oxctl "window list")
;;

let check_spawn_position_end_focus_disabled ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check spawn position end focus disabled"
    h
    [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position end";
  oxctl "window spawn focus disabled";
  with_kitty h (fun () -> oxctl "window list")
;;

let check_spawn_rule_override ({ Harness.oxctl; _ } as h) =
  Harness.with_windows
    "check spawn rule override"
    h
    [ "firefox", 1; "emacs", 1; "mpv", 1 ]
  @@ fun () ->
  oxctl "window focus match --app-id=emacs";
  oxctl "window spawn position prev";
  oxctl "window rules add --app-id=kitty --spawn-position=end --spawn-focus=disabled";
  with_kitty h (fun () -> oxctl "window list")
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_spawn_position_next h;
  check_spawn_position_prev h;
  check_spawn_position_end_focus_disabled h;
  check_spawn_rule_override h
;;
