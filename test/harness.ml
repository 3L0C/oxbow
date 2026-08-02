let socket_path = Printf.sprintf "./ocdwm-test-%d.sock" (Unix.getpid ())

exception Script_done

let rec wait_for ?(tries = 100) p =
  if p ()
  then ()
  else if tries = 0
  then failwith "condition not reached"
  else (
    Eio.Fiber.yield ();
    wait_for ~tries:(tries - 1) p)
;;

let section name = Printf.printf "== %s ==\n" name
let dump_trace fake = List.iter print_endline (Fake_river.trace fake)
let seen = ref 0

let settle fake =
  let rec go stable =
    if stable >= 10
    then ()
    else if Fake_river.idle fake
    then (
      Eio.Fiber.yield ();
      go (stable + 1))
    else (
      Eio.Fiber.yield ();
      go 0)
  in
  go 0
;;

let dump_new fake =
  settle fake;
  let all = Fake_river.trace fake in
  let fresh = List.filteri (fun i _ -> i >= !seen) all in
  List.iter print_endline fresh;
  seen := List.length all
;;

let ipc env body =
  match Ocdwm_ipc.Client.send ~env ~socket:socket_path body with
  | Ok reply -> reply
  | Error (Connection_failed msg) | Error (Protocol msg) -> failwith msg
;;

let octl env args =
  let stash = ref None in
  (Ocdwm_ctl.Ctl_cli.dispatch_command_ref
   := fun ?render ?seat ?socket:_ body ->
        stash := Some (render, seat, body);
        0);
  let errbuf = Buffer.create 256 in
  let err = Format.formatter_of_buffer errbuf in
  let argv = Array.of_list ("octl" :: args) in
  let code = Cmdliner.Cmd.eval' ~err ~argv @@ Ocdwm_ctl.Cmd_octl.cmd ~version:"test" in
  Format.pp_print_flush err ();
  Buffer.contents errbuf
  |> String.split_on_char '\n'
  |> List.iter (fun l -> if l <> "" then Printf.printf "err: %s\n" l);
  if code <> 0 then Printf.printf "exit: %d\n" code;
  match !stash with
  | None -> ()
  | Some (render, seat, body) ->
    (match Ocdwm_ipc.Client.send ~env ?seat ~socket:socket_path body with
     | Ok (Some (`String s)) -> print_endline s
     | Ok (Some data) ->
       print_endline
         (match render with
          | None -> Yojson.Safe.to_string data
          | Some render -> render data)
     | Ok None -> ()
     | Error (Connection_failed msg | Protocol msg) -> Printf.printf "err: %s\n" msg)
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
    Eio.Fiber.first
      (fun () ->
         ignore
         @@ Ocdwm_runtime.Run.loop
              ~socket_path
              ~init_command:None
              ~transport:(Wayland.Unix_transport.of_socket client_sock)
              ~net:(Eio.Stdenv.net env)
              ~clock:(Eio.Stdenv.clock env)
              ())
      (fun () -> script env fake ~section:section_helper);
    raise Script_done
  with
  | Script_done -> ()
;;
