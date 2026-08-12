exception Script_done

type h_env =
  { env : Eio_unix.Stdenv.base
  ; fake : Fake_river.t
  ; section : string -> (unit -> unit) -> unit
  ; oxctl : string -> unit
  }

let socket_path = Printf.sprintf "./oxbow-test-%d.sock" (Unix.getpid ())
let display = ref None
let barrier () = Wayland.Client.sync (Option.get !display)

let rec wait_for ?(tries = 100) p =
  if p ()
  then ()
  else if tries = 0
  then failwith "condition not reached"
  else (
    barrier ();
    wait_for ~tries:(tries - 1) p)
;;

let section name = Printf.printf "\n== %s ==\n" name
let dump_trace fake = List.iter print_endline (Fake_river.trace fake)
let seen = ref 0

let settle fake =
  barrier ();
  while not @@ Fake_river.idle fake do
    barrier ()
  done;
  barrier ()
;;

let dump_new fake =
  settle fake;
  let all = Fake_river.trace fake in
  let fresh = List.filteri (fun i _ -> i >= !seen) all in
  List.iter print_endline fresh;
  seen := List.length all
;;

(* Run.loop binds the ipc socket late in its setup. Retry with yields until the
   bind wins the race with the script fiber. *)
let rec send ?seat ?(tries = 1000) env body =
  match Oxbow_ipc.Client.send ~env ?seat ~socket:socket_path body with
  | Error (Connection_failed _) when tries > 0 ->
    Eio.Fiber.yield ();
    send ?seat ~tries:(tries - 1) env body
  | r -> r
;;

let ipc env body =
  match send env body with
  | Ok reply -> reply
  | Error (Connection_failed msg) | Error (Protocol msg) -> failwith msg
;;

let oxctl env args =
  let stash = ref None in
  (Oxbow_ctl.Ctl_cli.dispatch_command_ref
   := fun ?render ?seat ?socket:_ body ->
        stash := Some (render, seat, body);
        0);
  let errbuf = Buffer.create 256 in
  let err = Format.formatter_of_buffer errbuf in
  let argv = Array.of_list ("oxctl" :: args) in
  let code = Cmdliner.Cmd.eval' ~err ~argv @@ Oxbow_ctl.Cmd_oxctl.cmd ~version:"test" in
  Format.pp_print_flush err ();
  Buffer.contents errbuf
  |> String.split_on_char '\n'
  |> List.iter (fun l -> if l <> "" then Printf.printf "err: %s\n" l);
  if code <> 0 then Printf.printf "exit: %d\n" code;
  match !stash with
  | None -> ()
  | Some (render, seat, body) ->
    (match send ?seat env body with
     | Ok (Some (`String s)) -> print_endline s
     | Ok (Some data) ->
       print_endline
         (match render with
          | None -> Yojson.Safe.to_string data
          | Some render -> render data)
     | Ok None -> ()
     | Error (Connection_failed msg | Protocol msg) -> Printf.printf "err: %s\n" msg)
;;

let raw_oxctl h args = oxctl h.env args

let with_windows name h spec body =
  let spawned = ref [] in
  h.section (name ^ ": setup") (fun () ->
    let tag = ref 1 in
    List.iter
      (fun (app_id, target) ->
         if target <> !tag
         then (
           raw_oxctl h [ "tag"; "view"; string_of_int target ];
           tag := target);
         spawned := Fake_river.spawn_window h.fake ~app_id:(Some app_id) :: !spawned)
      spec;
    if !tag <> 1 then raw_oxctl h [ "tag"; "view"; "1" ]);
  body ();
  h.section (name ^ ": teardown") (fun () ->
    List.iter (Fake_river.close h.fake) !spawned;
    raw_oxctl h [ "tag"; "view"; "1" ])
;;

let with_outputs name h spec body =
  let spawned = ref [] in
  h.section (name ^ ": setup") (fun () ->
    List.iter
      (fun (n, x, y) ->
         spawned := Fake_river.spawn_output h.fake ~x ~y ~name:n :: !spawned)
      spec);
  body ();
  h.section (name ^ ": teardown") (fun () ->
    List.iter (Fake_river.remove_output h.fake) !spawned)
;;

let with_seats name h spec body =
  let spawned = ref [] in
  h.section (name ^ ": setup") (fun () ->
    List.iter (fun n -> spawned := Fake_river.spawn_seat h.fake ~name:n :: !spawned) spec);
  body ();
  h.section (name ^ ": teardown") (fun () ->
    List.iter (Fake_river.remove_seat h.fake) !spawned)
;;

let run script =
  Eio_main.run
  @@ fun env ->
  try
    Eio.Switch.run
    @@ fun sw ->
    let server_sock, client_sock = Eio_unix.Net.socketpair_stream ~sw () in
    let fake = Fake_river.start ~sw server_sock in
    let section_helper name f =
      section name;
      f ();
      dump_new fake
    in
    let oxctl_helper t =
      let args = String.split_on_char ' ' t in
      section_helper t (fun () -> oxctl env args)
    in
    Eio.Fiber.first
      (fun () ->
         ignore
         @@ Oxbow_runtime.Run.loop
              ~socket_path
              ~init_command:None
              ~transport:(Wayland.Unix_transport.of_socket client_sock)
              ~on_display:(fun d -> display := Some d)
              ~net:(Eio.Stdenv.net env)
              ~clock:(Eio.Stdenv.clock env)
              ())
      (fun () ->
         (* Run.loop registers the socket unlink hook before the bind
            creates the file (eio_linux listen). Wait for the file, so
            a fast script cannot cancel Run.loop inside that window. *)
         wait_for ~tries:10_000 (fun () -> Sys.file_exists socket_path);
         script { env; fake; section = section_helper; oxctl = oxctl_helper });
    raise Script_done
  with
  | Script_done -> ()
;;
