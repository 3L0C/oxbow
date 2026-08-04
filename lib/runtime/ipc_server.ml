[@@@landmark "auto-off"]

open! Oxbow_core
open! Oxbow_ipc
open! Oxbow_state

module Handler = struct
  let respond_err flow msg =
    let r = Response.{ ok = false; err = Some msg; data = None } in
    let s = Yojson.Safe.to_string (Response.yojson_of_t r) ^ "\n" in
    Eio.Flow.copy_string s flow
  ;;

  let respond_ok flow data =
    let r = Response.{ ok = true; err = None; data } in
    let s = Yojson.Safe.to_string (Response.yojson_of_t r) ^ "\n" in
    Eio.Flow.copy_string s flow
  ;;

  let validate ~wm:_ (body : Request.Body.t) =
    match body with
    | Command c ->
      (match c with
       | Spawn "" -> Error "spawn: empty command"
       | Exec [||] | Exec [| "" |] -> Error "exec: empty command"
       | _ -> Ok ())
    | Keymap _ | Query _ | Subscribe _ -> Ok ()
  ;;

  let resolve_seat (wm : Wm.t) (req : Request.t) =
    match req.seat with
    | Some name ->
      (match
         List.find_opt
           (fun (s : Seat.t) -> Option.fold ~none:false ~some:(fun n -> n = name) s.name)
           wm.seats
       with
       | Some s -> Ok s
       | None -> Error (Printf.sprintf "no seat named %S" name))
    | None ->
      Option.fold
        ~none:(Error "no primary seat available")
        ~some:(fun s -> Ok s)
        wm.primary_seat
  ;;

  let parse_json line =
    try Ok (Yojson.Safe.from_string line) with
    | Yojson.Json_error msg -> Error (Printf.sprintf "json parse: %s" msg)
  ;;

  let parse_request json =
    try Ok (Request.t_of_yojson json) with
    | Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (Failure msg, _) -> Error msg
    | Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error _ -> Error "invalid request shape"
  ;;

  let decode_line ~wm line =
    let open Result.Syntax in
    let* json = parse_json line in
    let* req = parse_request json in
    let* () = validate ~wm req.body in
    let* seat = resolve_seat wm req in
    Ok (req, seat)
  ;;

  let run_subscribe ~wm ~flow ~buf (s : Event.Subscribe.t) =
    respond_ok flow None;
    let kinds =
      match s.kinds with
      | [] -> Record.all
      | ks -> ks
    in
    let sub =
      Wm.Ipc.Subscriber.
        { kinds; output = s.output; pending = []; wake = Eio.Condition.create () }
    in
    Wm.add_subscriber wm sub;
    Events.seed wm sub;
    Fun.protect ~finally:(fun () -> Wm.remove_subscriber wm sub)
    @@ fun () ->
    try
      Eio.Fiber.first
        (fun () ->
           try ignore @@ Eio.Buf_read.line buf with
           | End_of_file -> ())
        (fun () ->
           while true do
             while sub.pending = [] do
               Eio.Condition.await_no_mutex sub.wake
             done;
             let batch = sub.pending in
             sub.pending <- [];
             List.iter (fun (_, line) -> Eio.Flow.copy_string (line ^ "\n") flow) batch
           done)
    with
    | Eio.Io _ -> ()
  ;;

  let handle_line ~wm ~flow ~buf line =
    match decode_line ~wm line with
    | Error e -> respond_err flow e
    | Ok (req, seat) ->
      (match req.body, wm.lifecycle with
       | Subscribe s, Running -> run_subscribe ~wm ~flow ~buf s
       | _, Running ->
         let p, u = Eio.Promise.create () in
         let open Pending_request in
         let request = { body = req.body; reply = Some u } in
         Seat.queue_pending seat request;
         (match Eio.Promise.await p with
          | Ok data -> respond_ok flow data
          | Error msg -> respond_err flow msg)
       | _, (Pending_exit _ | Exited | Close_requested) ->
         respond_err flow "wm shutting down")
  ;;

  let run ~wm flow =
    let buf = Eio.Buf_read.of_flow flow ~max_size:65536 in
    match Eio.Buf_read.line buf with
    | exception _ -> respond_err flow "read failed"
    | line -> handle_line ~wm ~flow ~buf line
  ;;
end

let accept_loop ~sw ~wm socket =
  let rec loop () =
    let outcome =
      Eio.Fiber.first
        (fun () ->
           Lifecycle.await_shutdown wm;
           `Shutdown)
        (fun () ->
           Eio.Net.accept_fork
             ~sw
             socket
             ~on_error:(fun exn ->
               Logs.warn @@ fun m -> m "ipc handler crashed: %s" (Printexc.to_string exn))
             (fun flow _addr ->
                Eio.Fiber.first
                  (fun () -> Lifecycle.await_shutdown wm)
                  (fun () -> Handler.run ~wm flow));
           `Accepted)
    in
    match outcome with
    | `Shutdown -> ()
    | `Accepted -> loop ()
  in
  loop ()
;;

let start ?socket_path ~sw ~net ~wm () =
  let path = Socket_path.resolve ?override:socket_path () in
  Unix.putenv "OXBOW_SOCKET" path;
  let socket = Eio.Net.listen ~sw ~backlog:128 ~reuse_addr:true net (`Unix path) in
  Eio.Fiber.fork ~sw (fun () -> accept_loop ~sw ~wm socket);
  Logs.info @@ fun m -> m "ipc: listening on %s" path
;;
