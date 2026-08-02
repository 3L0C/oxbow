let () =
  Harness.run
  @@ fun env fake ~section ->
  let o name args = section name (fun () -> Harness.octl env args) in
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  o "bind focus next" [ "bind"; "window"; "focus"; "next"; "to"; "Super+J" ];
  section "press the bind" (fun () ->
    Fake_river.press_binding fake ~index:(Fake_river.binding_count fake - 1));
  o "unbind" [ "unbind"; "Super+J" ];
  section "focused" (fun () ->
    Harness.ipc env (Query Focused)
    |> Option.iter (fun j -> print_endline (Yojson.Safe.to_string j)))
;;
