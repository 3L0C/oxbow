let () =
  Harness.run
  @@ fun env fake ~section ->
  let o name args = section name (fun () -> Harness.octl env args) in
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty");
    Fake_river.add_window fake ~app_id:(Some "emacs"));
  o "warp on" [ "input"; "pointer"; "warp"; "on" ];
  o "focus next warps" [ "window"; "focus"; "next" ];
  o "focus next, --no-warp wins" [ "window"; "focus"; "next"; "--no-warp" ];
  o "warp off" [ "input"; "pointer"; "warp"; "off" ];
  o "focus next stays" [ "window"; "focus"; "next" ];
  o "focus next, --warp wins" [ "window"; "focus"; "next"; "--warp" ]
;;
