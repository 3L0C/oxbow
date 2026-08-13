let check_window_manage { Harness.fake; section; oxctl; _ } =
  let window = ref None in
  section "check window manage" (fun () ->
    window := Some (Fake_river.spawn_window fake ~app_id:(Some "foot"));
    Fake_river.tick fake);
  oxctl "window list";
  section "check window manage teardown" (fun () ->
    Option.iter (Fake_river.close fake) !window)
;;

let check_output_list ({ Harness.oxctl; _ } as h) =
  Harness.with_windows "check output list" h [] @@ fun () -> oxctl "output list"
;;

let check_idle_quiet { Harness.section; _ } =
  section "check idle quiet" (fun () ->
    for _ = 1 to 100 do
      Eio.Fiber.yield ()
    done)
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_window_manage h;
  check_output_list h;
  check_idle_quiet h
;;
