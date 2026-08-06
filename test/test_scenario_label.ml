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
  o "window list - expect []" [ "window"; "list"; "--label=none" ]
;;
