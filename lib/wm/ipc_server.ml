[@@@landmark "auto-off"]

open! Ocdwm_core

let accept_loop ~sw ~wm socket =
  let rec loop () =
    let outcome =
      Eio.Fiber.first
        (fun () ->
           Window_manager.await_shutdown wm;
           `Shutdown)
        (fun () ->
           let flow, _addr = Eio.Net.accept ~sw socket in
           `Conn flow)
    in
    match outcome with
    | `Shutdown -> ()
    | `Conn flow ->
      Eio.Fiber.fork ~sw (fun () ->
        try Ipc_handler.run ~wm flow with
        | Eio.Cancel.Cancelled _ ->
          Logs.debug @@ fun m -> m "Ipc_handler.run failed: wm shutting down"
        | exn ->
          Logs.warn @@ fun m -> m "ipc handler crashed: %s" (Printexc.to_string exn));
      loop ()
  in
  loop ()
;;

let start ~sw ~net ~wm =
  let path = Socket_path.resolve () in
  let socket = Eio.Net.listen ~sw ~backlog:128 ~reuse_addr:true net (`Unix path) in
  Eio.Fiber.fork ~sw (fun () -> accept_loop ~sw ~wm socket);
  Logs.info @@ fun m -> m "ipc: listening on %s" path
;;
