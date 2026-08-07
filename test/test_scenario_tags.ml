let cmd env (c : Oxbow_ipc.Command.t) = ignore @@ Harness.ipc env (Command c)

let () =
  Harness.run
  @@ fun env fake ~section ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  section "move focused window to tag 2" (fun () ->
    cmd
      env
      (Window
         (Tag
            { tags = Concrete (Oxbow_core.Tag.Set.singleton 2)
            ; follow = false
            ; target = Focused
            })));
  section "view tag 2" (fun () ->
    cmd env (Tag (View (Concrete (Oxbow_core.Tag.Set.singleton 2)))));
  section "view previous" (fun () -> cmd env (Tag View_previous));
  section "toggle view of tag 2" (fun () ->
    cmd env (Tag (Toggle_view (Oxbow_core.Tag.Set.singleton 2))));
  section "tags" (fun () ->
    Harness.ipc env (Query (Tags { output = None }))
    |> Option.iter (fun j -> print_endline @@ Yojson.Safe.to_string j))
;;
