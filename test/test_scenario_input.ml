let () =
  Harness.run
  @@ fun env fake ~section ->
  let o name args = section name (fun () -> Harness.oxctl env args) in
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  o
    "mouse rule"
    [ "input"
    ; "rules"
    ; "mouse"
    ; "--name"
    ; "Logitech.*"
    ; "--natural-scroll"
    ; "enabled"
    ; "--accel-speed"
    ; "0.5"
    ];
  o
    "second mouse rule"
    [ "input"; "rules"; "mouse"; "--name"; ".*"; "--left-handed"; "enabled" ];
  o "rules list" [ "input"; "rules"; "list" ];
  o "rules remove" [ "input"; "rules"; "remove"; "0" ];
  o "rules list again" [ "input"; "rules"; "list" ];
  o "rules remove out of range" [ "input"; "rules"; "remove"; "5" ]
;;
