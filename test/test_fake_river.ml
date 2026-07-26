let setup () =
  Logs.set_reporter @@ Logs_fmt.reporter ();
  Logs.(set_level ~all:true (Some Info));
  Sys.set_signal Sys.sigchld Sys.Signal_ignore;
  Printexc.record_backtrace true
;;

exception Script_done

let run_wm script =
  Eio_main.run
  @@ fun env ->
  try
    Eio.Switch.run
    @@ fun sw ->
    let server_sock, client_sock = Eio_unix.Net.socketpair_stream ~sw () in
    let fake = Fake_river.start ~sw server_sock in
    Eio.Fiber.first
      (fun () ->
         ignore
         @@ Ocdwm_runtime.Run.loop
              ~socket_path:"./ocdwm-1.sock"
              ~init_command:None
              ~transport:(Wayland.Unix_transport.of_socket client_sock)
              ~net:(Eio.Stdenv.net env)
              ~clock:(Eio.Stdenv.clock env)
              ())
      (fun () -> script fake);
    raise Script_done
  with
  | Script_done -> ()
;;

let rec wait_for ?(tries = 100) p =
  if p ()
  then ()
  else if tries = 0
  then failwith "condition not reached"
  else (
    Eio.Fiber.yield ();
    wait_for ~tries:(tries - 1) p)
;;

let test_boot () = run_wm @@ fun fake -> Fake_river.add_output fake ~name:"FAKE-1"

let test_admit () =
  run_wm
  @@ fun fake ->
  Fake_river.add_output fake ~name:"FAKE-1";
  Fake_river.add_window fake ~app_id:(Some "foot");
  assert (List.mem "manage:propose_dimensions" (Fake_river.trace fake))
;;

let test_inlet_schedule () =
  run_wm
  @@ fun fake ->
  Fake_river.add_output fake ~name:"FAKE-1";
  Fake_river.add_seat fake ~name:"seat0";
  let before = Fake_river.manage_dirty_count fake in
  Fake_river.press_binding fake ~index:0;
  wait_for (fun () -> Fake_river.manage_dirty_count fake > before)
;;

let test_idle_quiet () =
  run_wm
  @@ fun fake ->
  Fake_river.add_output fake ~name:"FAKE-1";
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
