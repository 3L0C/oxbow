let () =
  Harness.run
  @@ fun env fake ~section ->
  let o name args = section name (fun () -> Harness.oxctl env args) in
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty"));
  o "window label add - scratch" [ "window"; "label"; "add"; "scratch" ];
  o "window label add - term" [ "window"; "label"; "add"; "term" ];
  o "window label add - scratch (no-op)" [ "window"; "label"; "add"; "scratch" ];
  o "window list - expect [term;scratch]" [ "window"; "list" ];
  o "window label remove - scratch" [ "window"; "label"; "remove"; "scratch" ];
  o "window list - expect [term]" [ "window"; "list" ];
  o "output label add - main" [ "output"; "label"; "add"; "main" ];
  o "output list - expect [main]" [ "output"; "list" ];
  o "window label add empty - expect error" [ "window"; "label"; "add"; "" ];
  o "output label add empty - expect error" [ "output"; "label"; "add"; "" ]
;;
