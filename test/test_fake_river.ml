let setup () =
  Logs.set_reporter @@ Logs_fmt.reporter ();
  Logs.(set_level ~all:true (Some Info));
  Sys.set_signal Sys.sigchld Sys.Signal_ignore;
  Printexc.record_backtrace true
;;

let test_boot () =
  Harness.run @@ fun _env fake ~section:_ -> Fake_river.add_output fake ~name:"FAKE-1"
;;

let test_admit () =
  Harness.run
  @@ fun _env fake ~section:_ ->
  Fake_river.add_output fake ~name:"FAKE-1";
  Fake_river.add_window fake ~app_id:(Some "foot");
  assert (
    List.exists
      (String.starts_with ~prefix:"manage:propose_dimensions")
      (Fake_river.trace fake))
;;

let test_inlet_schedule () =
  Harness.run
  @@ fun _env fake ~section:_ ->
  Fake_river.add_output fake ~name:"FAKE-1";
  Fake_river.add_seat fake ~name:"seat0";
  let before = Fake_river.manage_dirty_count fake in
  Fake_river.press_binding fake ~index:0;
  Harness.wait_for (fun () -> Fake_river.manage_dirty_count fake > before)
;;

let test_idle_quiet () =
  Harness.run
  @@ fun _env fake ~section:_ ->
  Fake_river.add_output fake ~name:"FAKE-1";
  for _ = 1 to 100 do
    Eio.Fiber.yield ()
  done;
  let snapshot () =
    List.length (Fake_river.trace fake), Fake_river.manage_dirty_count fake
  in
  let before = snapshot () in
  for _ = 1 to 100 do
    Eio.Fiber.yield ()
  done;
  assert (before = snapshot ())
;;

let () =
  setup ();
  test_boot ();
  test_admit ();
  test_inlet_schedule ();
  test_idle_quiet ()
;;
