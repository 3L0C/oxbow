let wait_stable lines =
  let rec go last stable =
    if stable >= 50
    then ()
    else (
      Eio.Fiber.yield ();
      let n = List.length !lines in
      if n = last then go last (stable + 1) else go n 0)
  in
  go (List.length !lines) 0
;;

let check_subscribe ({ Harness.env; fake; section; oxctl } as h) =
  Harness.with_windows "check subscribe" h [ "kitty", 1 ]
  @@ fun () ->
  let lines = ref [] in
  Eio.Fiber.first
    (fun () ->
       ignore
       @@ Oxbow_ipc.Client.subscribe ~env ~socket:Harness.socket_path ~kinds:[] (fun l ->
         lines := l :: !lines))
    (fun () ->
       oxctl "tag view 2";
       let emacs = Harness.spawn ~section:"spawn emacs" h "emacs" in
       oxctl "layout scrolling";
       oxctl "keymap mode declare resize";
       oxctl "keymap mode enter resize";
       oxctl "window focus next";
       section "capture output" (fun () ->
         Fake_river.send_output_capture_sessions fake ~name:"FAKE-1" ~count:1l);
       Harness.settle fake;
       wait_stable lines;
       Harness.section "events";
       List.rev !lines |> List.iter print_endline;
       Harness.section "events human";
       List.rev !lines
       |> List.iter (fun l -> print_endline (Oxbow_ctl.Ctl_cli.render_event l));
       Harness.close h emacs)
;;

let () =
  Harness.run
  @@ fun ({ Harness.fake; section; _ } as h) ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0");
  check_subscribe h
;;
