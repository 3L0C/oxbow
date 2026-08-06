let cmd env (c : Oxbow_ipc.Command.t) = ignore @@ Harness.ipc env (Command c)

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

let () =
  Harness.run
  @@ fun env fake ~section ->
  section "arrive" (fun () ->
    Fake_river.add_output fake ~name:"FAKE-1";
    Fake_river.add_seat fake ~name:"seat0";
    Fake_river.add_window fake ~app_id:(Some "kitty"));
  let lines = ref [] in
  Eio.Fiber.first
    (fun () ->
       ignore
       @@ Oxbow_ipc.Client.subscribe ~env ~socket:Harness.socket_path ~kinds:[] (fun l ->
         lines := l :: !lines))
    (fun () ->
       cmd env (Tag (View (Concrete (Oxbow_core.Tag.Set.singleton 2))));
       Fake_river.add_window fake ~app_id:(Some "emacs");
       cmd env (Layout (Select { layout = Scrolling; scope = Focused }));
       cmd env (Keymap (Mode (Declare "resize")));
       cmd env (Keymap (Mode (Enter "resize")));
       cmd env (Window (Focus_logical { dir = Next; warp = None }));
       Harness.settle fake;
       wait_stable lines;
       Harness.section "events";
       List.rev !lines |> List.iter print_endline)
;;
