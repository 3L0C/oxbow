let cmd env (c : Oxbow_ipc.Command.t) = ignore @@ Harness.ipc env (Command c)

let () =
  Harness.run
  @@ fun env fake ~section ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  section "emacs tag 2" (fun () ->
    cmd
      env
      (Window
         (Tag
            { tags = Concrete (Oxbow_core.Tag.Set.singleton 2)
            ; follow = false
            ; target = One Focused
            })));
  section "sticky kitty - all" (fun () ->
    cmd env (Window (Set_sticky { scope = All; target = One Focused })));
  section "view tag 2" (fun () ->
    cmd env (Tag (View (Concrete (Oxbow_core.Tag.Set.singleton 2)))));
  section "sticky kitty - occupied" (fun () ->
    cmd env (Window (Set_sticky { scope = Occupied; target = One Focused })));
  section "view tag 3" (fun () ->
    cmd env (Tag (View (Concrete (Oxbow_core.Tag.Set.singleton 3)))));
  section "focused" (fun () ->
    Harness.ipc env (Query Focused)
    |> Option.iter (fun j -> print_endline @@ Yojson.Safe.to_string j))
;;
