let () =
  Harness.run
  @@ fun env fake ~section ->
  let o name args = section name (fun () -> Harness.oxctl env args) in
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  o "focus kitty" [ "window"; "focus"; "match"; "--app-id=kitty" ];
  o "kitty: label add - scratch" [ "window"; "label"; "add"; "scratch" ];
  o "kitty: label add - term" [ "window"; "label"; "add"; "term" ];
  o "kitty: label add - scratch (no-op)" [ "window"; "label"; "add"; "scratch" ];
  o "window list - expect [term;scratch]" [ "window"; "list" ];
  o "kitty: label remove - scratch" [ "window"; "label"; "remove"; "scratch" ];
  o "window list - expect [term]" [ "window"; "list" ];
  o "FAKE-1: label add - main" [ "output"; "label"; "add"; "main" ];
  o "output list - expect [main]" [ "output"; "list" ];
  o "kitty: label add - empty (expect error)" [ "window"; "label"; "add"; "" ];
  o "FAKE-1: label add empty - (expect error)" [ "output"; "label"; "add"; "" ];
  o "focus emacs" [ "window"; "focus"; "match"; "--app-id=emacs" ];
  o "emacs: label add - term" [ "window"; "label"; "add"; "term" ];
  o "focus --label=term" [ "window"; "focus"; "match"; "--label=term" ];
  o "focus --cycle --label=term" [ "window"; "focus"; "match"; "--cycle"; "--label=term" ];
  o "window list - expect [term]" [ "window"; "list"; "--label=te.*" ];
  o "window list - expect []" [ "window"; "list"; "--label=none" ];
  o
    "label-as - video_player"
    [ "window"; "rules"; "add"; "--label-as=video_player"; "--app-id=mpv" ];
  o
    "label-as - browser"
    [ "window"; "rules"; "add"; "--label-as=browser"; "--app-id=firefox" ];
  section "test label-as rule" (fun () ->
    Fake_river.add_window fake ~app_id:(Some "firefox");
    Fake_river.add_window fake ~app_id:(Some "mpv"));
  o "window list - expect [mpv]" [ "window"; "list"; "--label=video_player" ];
  o "window list - expect [firefox]" [ "window"; "list"; "--label=browser" ];
  section "test output labels" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-2";
    Fake_river.add_output fake ~name:"FAKE-3");
  o "output label" [ "output"; "label"; "add"; "--name=FAKE-1"; "first" ];
  o "output label" [ "output"; "label"; "add"; "--name=FAKE-2"; "second" ];
  o "output label" [ "output"; "label"; "add"; "--name=FAKE-3"; "third" ];
  o "output focus label" [ "output"; "focus"; "match"; "--label=second" ];
  o "window list - expect [FAKE-2]" [ "output"; "list" ];
  o "output focus label" [ "output"; "focus"; "match"; "--label=first" ];
  o "window list - expect [FAKE-1]" [ "output"; "list" ];
  o "output focus label" [ "output"; "focus"; "match"; "--label=third" ];
  o "window list - expect [FAKE-3]" [ "output"; "list" ]
;;
