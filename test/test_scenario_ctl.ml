let () =
  Harness.run
  @@ fun env fake ~section ->
  let o name args = section name (fun () -> Harness.oxctl env args) in
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty"));
  o
    "rules add"
    [ "window"; "rules"; "add"; "--app-id"; "^mpv$"; "--float"; "--tags"; "3" ];
  section "mpv arrives floating on tag 3" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  o "rules list" [ "window"; "rules"; "list" ];
  o "rules remove" [ "window"; "rules"; "remove"; "0" ];
  o "rules remove out of range" [ "window"; "rules"; "remove"; "7" ];
  section "third window" (fun () -> Fake_river.add_window fake ~app_id:(Some "emacs"));
  o "gaps inner, focused" [ "gaps"; "inner"; "4" ];
  o "gaps inner, output" [ "gaps"; "inner"; "6"; "--output"; "FAKE-1" ];
  o "gaps inner, all" [ "gaps"; "inner"; "8"; "--all" ];
  o "window list" [ "window"; "list" ];
  o "window list json" [ "window"; "list"; "--json" ]
;;
