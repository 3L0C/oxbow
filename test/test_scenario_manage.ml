let () =
  Harness.run
  @@ fun env fake ~section ->
  section "trace" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "foot");
    Fake_river.tick fake);
  section "outputs" (fun () ->
    Harness.ipc env (Query Ocdwm_ipc.Query.Outputs)
    |> Option.iter (fun j -> print_endline (Yojson.Safe.to_string j)))
;;
