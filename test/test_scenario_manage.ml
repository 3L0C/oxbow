let () =
  Harness.run
  @@ fun { Harness.fake; section; oxctl; _ } ->
  section "trace" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "foot");
    Fake_river.tick fake);
  oxctl "output list";
  section "idle quiet" (fun () ->
    for _ = 1 to 100 do
      Eio.Fiber.yield ()
    done)
;;
